// lib/core/auth/auth_interceptor.dart
import 'dart:async';
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthInterceptor implements InterceptorContract {
  final AuthService _authService;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  AuthInterceptor(this._authService);

  @override
  Future<http.BaseRequest> interceptRequest({
    required http.BaseRequest request,
  }) async {
    // Skip login/register endpoints
    if (request.url.path.startsWith('/auth') &&
        !request.url.path.endsWith('/refresh')) {
      return request;
    }

    final token = await _authService.getValidAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return request;
  }

  @override
  Future<http.BaseResponse> interceptResponse({
    required http.BaseResponse response,
  }) async {
    // Handle only http.Response objects
    if (response is http.Response && response.statusCode == 401) {
      final originalRequest = response.request!;
      final completer = Completer<http.Response>();

      _pendingRequests.add(_PendingRequest(originalRequest, completer));

      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final newToken = await _authService.refreshAccessToken();
          if (newToken != null) {
            // Retry all pending requests with new token
            for (final pending in _pendingRequests) {
              final retriedRequest = await _cloneRequestWithToken(
                pending.request,
                newToken,
              );
              try {
                final retriedResponse = await http.Response.fromStream(
                  await http.Client().send(retriedRequest),
                );
                pending.completer.complete(retriedResponse);
              } catch (e) {
                pending.completer.completeError(e);
              }
            }
          } else {
            // Refresh failed → logout
            await _authService.logout();
            for (final pending in _pendingRequests) {
              pending.completer.completeError(
                Exception('Session expired. Please log in again.'),
              );
            }
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        } finally {
          _isRefreshing = false;
          _pendingRequests.clear();
        }
      }

      return completer.future;
    }

    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest() => true;

  @override
  FutureOr<bool> shouldInterceptResponse() => true;

  Future<http.Request> _cloneRequestWithToken(
    http.BaseRequest request,
    String token,
  ) async {
    final newRequest = http.Request(request.method, request.url);
    newRequest.headers.addAll(request.headers);
    newRequest.headers['Authorization'] = 'Bearer $token';

    if (request is http.Request) {
      newRequest.bodyBytes = request.bodyBytes;
    }
    return newRequest;
  }
}

class _PendingRequest {
  final http.BaseRequest request;
  final Completer<http.Response> completer;
  _PendingRequest(this.request, this.completer);
}
