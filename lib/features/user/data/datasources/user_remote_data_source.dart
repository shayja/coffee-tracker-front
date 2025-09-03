// lib/features/user/data/datasources/user_remote_data_source.dart
import 'dart:convert';
import 'dart:io';
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/features/user/domain/entities/user.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

abstract class UserRemoteDataSource {
  Future<User> getProfile();
  Future<void> updateProfile(User user);
  Future<String> uploadAvatar(File file);
  Future<void> deleteAvatar();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final AuthService authService;
  final Duration timeout = const Duration(seconds: 10);

  UserRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authService,
  });

  @override
  Future<User> getProfile() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  @override
  Future<void> updateProfile(User user) async {
    final headers = await _getHeaders();
    final response = await client.patch(
      Uri.parse('$baseUrl/user/profile'),
      headers: headers,
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  @override
  Future<String> uploadAvatar(File file) async {
    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/user/avatar'),
    );
    final headers = await _getHeaders();
    request.headers.addAll(headers);
    request.files.add(
      http.MultipartFile(
        'file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: basename(file.path),
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return jsonBody['avatar_url'];
    } else {
      throw Exception('Failed to upload avatar');
    }
  }

  @override
  Future<void> deleteAvatar() async {
    final headers = await _getHeaders();
    final response = await client.delete(
      Uri.parse('$baseUrl/user/avatar'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete avatar');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await authService.getValidAccessToken();

    // If token is null or expired, try to refresh
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
