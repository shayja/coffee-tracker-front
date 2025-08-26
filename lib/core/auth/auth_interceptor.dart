// lib/core/auth/auth_interceptor.dart
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

class AuthInterceptor implements InterceptorContract {
  final AuthService authService;
  bool _isRefreshing = false;
  final List<http.BaseRequest> _pendingRequests = [];

  AuthInterceptor(this.authService);

  @override
  Future<http.BaseRequest> interceptRequest({
    required http.BaseRequest request,
  }) async {
    // Skip adding token for auth endpoints (except refresh)
    if (request.url.path.contains('/auth') &&
        !request.url.path.contains('/auth/refresh')) {
      return request;
    }

    // Add Authorization header if token exists
    final token = await authService.getAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return request;
  }

  @override
  Future<http.BaseResponse> interceptResponse({
    required http.BaseResponse response,
  }) async {
    // Log token status for 401 errors
    if (response.statusCode == 401) {
      await authService.logTokenStatus();
    }

    // Only handle 401 Unauthorized responses
    if (response.statusCode != 401) {
      return response;
    }

    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      _pendingRequests.add(response.request!);
      return response; // Will be retried after refresh completes
    }

    _isRefreshing = true;

    try {
      // Attempt to refresh token
      final refreshed = await authService.refreshToken();
      if (!refreshed) {
        _isRefreshing = false;
        return response; // Refresh failed
      }

      // Get new token
      final newToken = await authService.getAccessToken();
      if (newToken == null) {
        _isRefreshing = false;
        return response; // No token available
      }

      // Retry all pending requests with new token
      for (final pendingRequest in _pendingRequests) {
        final newRequest = _cloneRequestWithToken(pendingRequest, newToken);
        await http.Client().send(newRequest);
      }

      // Clear pending requests
      _pendingRequests.clear();

      // Retry the original request
      final originalRequest = response.request!;
      final newRequest = _cloneRequestWithToken(originalRequest, newToken);

      final newResponse = await http.Client()
          .send(newRequest)
          .then(http.Response.fromStream);

      _isRefreshing = false;
      return newResponse;
    } catch (e) {
      _isRefreshing = false;
      _pendingRequests.clear();
      return response; // Return original response if anything fails
    }
  }

  http.BaseRequest _cloneRequestWithToken(
    http.BaseRequest original,
    String token,
  ) {
    final newRequest = http.Request(original.method, original.url)
      ..headers.addAll({...original.headers, 'Authorization': 'Bearer $token'});

    if (original is http.Request) {
      newRequest.bodyBytes = original.bodyBytes;
    }

    return newRequest;
  }

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;
}
