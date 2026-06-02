/// الكلاس الأساسي لجميع الاستثناءات المخصصة.
///
/// يُستخدم في طبقة الـ Data لرمي استثناءات صريحة
/// يتم التقاطها وتحويلها إلى [Failure] في الـ Repository.
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// استثناء ناتج عن قاعدة البيانات المحلية (SQLite).
class LocalDatabaseException extends AppException {
  const LocalDatabaseException(super.message);
}

/// استثناء ناتج عن الخادم أو الاتصال البعيد (MySQL/API).
class ServerException extends AppException {
  const ServerException(super.message);
}

/// استثناء ناتج عن عدم العثور على البيانات المطلوبة.
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
