// lib/exceptions/custom_exception.dart

class CustomException implements Exception {
  final String message;

  CustomException(this.message);

  @override
  String toString() => message;
}
