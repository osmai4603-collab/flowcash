/// الكلاس الأساسي لجميع الترقيمات المتقدمة (Class-based Enums).
///
/// يوفر واجهة موحدة للتعامل مع الترقيمات عبر التطبيق
/// مع دعم الترجمة والتحويل من/إلى نصوص.
abstract class AppEnum {
  const AppEnum();

  /// الاسم البرمجي للترقيم (يُستخدم للتخزين والمقارنة).
  String get name;

  /// ترتيب الترقيم في القائمة.
  int get index;

  @override
  String toString() {
    return name;
  }

  String displayName();
}
