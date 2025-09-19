import 'package:coffee_tracker/core/auth/auth_service.dart';

class ApiUtils {
  final AuthService authService;

  ApiUtils(this.authService);

  Future<Map<String, String>> getHeaders() async {
    String? token = await authService.getValidAccessToken();

    if (token == null || (await authService.isTokenExpired(token))) {
      final refreshed = await authService.refreshToken();
      if (refreshed != null) {
        token = await authService.getValidAccessToken();
      } else {
        throw Exception('Authentication required - please login again');
      }
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
