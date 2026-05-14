class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic error;

  AppException(this.message, {this.code, this.error});

  @override
  String toString() =>
      'AppException: $message ${code != null ? '[$code]' : ''}';
}

// Các exception cụ thể hơn nếu cần
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.error});
}

class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code, super.error});
}

class PermissionException extends AppException {
  PermissionException(super.message, {super.code, super.error});
}
