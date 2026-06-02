import 'package:equatable/equatable.dart';

/// الكلاس الأساسي لجميع الكائنات (Entities) في طبقة الـ Domain.
///
/// يوفر المساواة المبنية على القيم (Value-based Equality)
/// عبر وراثة [Equatable].
abstract class Entity extends Equatable {
  const Entity();

  /// يجب أن ينفذها كل كائن فرعي لتحديد
  /// إمكانية النسخ مع التعديل.
  Entity copyWith();
}
