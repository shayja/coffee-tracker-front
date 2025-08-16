// lib/core/auth/auth_interceptor.dart
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

class AuthInterceptor implements InterceptorContract {
  final AuthService authService;

  AuthInterceptor(this.authService);

  @override
  Future<http.BaseRequest> interceptRequest({
    required http.BaseRequest request,
  }) async {
    // Skip adding token for auth endpoints
    if (request.url.path.contains('/auth')) {
      return request;
    }

    final token = await authService.accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return request;
  }

  @override
  Future<http.BaseResponse> interceptResponse({
    required http.BaseResponse response,
  }) async {
    print('[Interceptor] Response from: ${response.request?.url}');
    print('[Interceptor] Status: ${response.statusCode}');

    if (response is http.Response) {
      print('[Interceptor] Response body: ${response.body}');
    }

    // Only handle 401 Unauthorized responses
    if (response.statusCode != 401) {
      return response;
    }

    try {
      // Attempt to refresh token
      final refreshed = await authService.refreshToken();
      if (!refreshed) {
        return response; // Refresh failed, return original response
      }

      // Get new token
      final newToken = await authService.accessToken;
      if (newToken == null) {
        return response; // No token available
      }

      // Clone original request with new token
      final originalRequest = response.request as http.Request;
      final newRequest =
          http.Request(originalRequest.method, originalRequest.url)
            ..headers.addAll({
              ...originalRequest.headers,
              'Authorization': 'Bearer $newToken',
            })
            ..bodyBytes = originalRequest.bodyBytes;

      // Retry the request
      return await http.Client()
          .send(newRequest)
          .then(http.Response.fromStream);
    } catch (e) {
      return response; // Return original response if anything fails
    }
  }

  // These must return true to enable interception
  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;
}
