import 'package:equatable/equatable.dart';

/// الكلاس الأساسي لجميع حالات الفشل (Failures).
///
/// يُستخدم كنوع الخطأ في [Either<Failure, T>] لتوحيد
/// معالجة الأخطاء عبر جميع طبقات التطبيق.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// فشل ناتج عن قاعدة البيانات المحلية (SQLite).
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure(super.message);
}

/// فشل ناتج عن قاعدة البيانات المحلية (SQLite).
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// فشل ناتج عن الخادم أو الاتصال البعيد (MySQL/API).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// فشل ناتج عن خطأ غير متوقع.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

/// فشل ناتج عن عدم العثور على البيانات المطلوبة.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// فشل ناتج عن التحقق من صحة البيانات.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
