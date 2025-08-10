// If your ServerException doesn't have a message parameter,
class ServerException implements Exception {
  final String message;

  const ServerException({this.message = 'Server error occurred'});

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {}
