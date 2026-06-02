## Plan: نقل موارد الحسابات من `core` إلى ميزة `accounts`

TL;DR - الهدف: نقل كل ما يتعلق بالحسابات (entities, repositories interfaces/impl, datasources interfaces/impl, usecases) من مجلد `lib/core` إلى ميزة تحت `lib/features/accounts`، مع تحديث الاستيرادات، حاوية الاعتماديات، والاختبارات. ملفات الجداول والـ enums لن تُنقل.

**Steps**
1. اكتشاف (مكتمل): حصر كل ملفات ومراجع الحسابات داخل `lib/core` (entities, repositories interfaces/impl, datasources interfaces/impl, usecases). *تبعاً للنتيجة المبدئية تم جمع قائمة ملفات مرتبطة*. (لا تحتاج لخطوة إضافية إلا إذا أردت تفصيل أكثر)
2. تحديد بنية الهدف: إنشاء المجلدات التالية تحت `lib/features/accounts` (إن لم تكن موجودة):
   - `lib/features/accounts/entities/`
   - `lib/features/accounts/repositories/interfaces/`
   - `lib/features/accounts/repositories/implementations/`
   - `lib/features/accounts/datasources/interfaces/`
   - `lib/features/accounts/datasources/implementations/`
   - `lib/features/accounts/usecases/`
   - **الجداول:** ستبقى في `lib/core/tables` ولن تُنقل.
3. نسخ/نقل الملفات (مجموعة بنوعية الملف):
   - نقل `entities` كلها من `lib/core/entities/*` إلى `lib/features/accounts/entities/`.
   - نقل واجهات المستودعات من `lib/core/repositories/interfaces/*` إلى `lib/features/accounts/repositories/interfaces/`.
   - نقل (إن وجدت) تنفيذات المستودعات إلى `lib/features/accounts/repositories/implementations/`.
   - نقل datasource interfaces و implementations من `lib/core/datasources/*` إلى المسارات المقابلة تحت `lib/features/accounts/datasources/`.
   - نقل `usecases` المتعلقة بـ main/sub accounts إلى `lib/features/accounts/usecases/` (حافظ على أسماء الملفات لكن اجعلها feature-scoped).
   - **ملاحظة:** ملفات الجداول (`tables`) وملفات `enums` ستبقى في `lib/core` ولن تُنقل.
4. تحديث الاستيرادات: تحديث كل import paths في الملفات المنقولة وأيضاً تحديث أي ملف خارجية يستورد هذه الأنواع ليشير إلى `package:flowcash/features/accounts/...` بدلاً من `package:flowcash/core/...`.
5. تحديث حاوية الاعتماديات / DI: تعديل `lib/core/injection_container.dart` أو مكان تسجيل المستودعات والداتا سورسات لنقل التسجيلات الخاصة بالحسابات إلى ملف حاوية داخل `features/accounts` أو تحديث المسارات المسجلة.
6. تحديث المسارات في الشيفرة المستدعية: البحث عن أي استدعاءات لـ usecases/repositories قد تحتاج لتحديث المسار أو إعادة تصدير (re-export) من `core` إذا أردنا الاحتفاظ بواجهة مستقرة.
7. التحقق الآلي والاختبارات: تشغيل تحققات البناء والاختبارات الوحدوية المتاحة والتأكد من أن كل شيء يبني.
8. تنظيف: إزالة الملفات الفارغة أو المكررة من `lib/core` وإنشاء ملفات re-export إن رغبت بواجهة انتقالية (مثلاً `lib/core/accounts.dart` التي تعيد تصدير الأنواع من `features/accounts` لفترة انتقالية).
9. مراجعة وتوثيق: تحديث README أو docs (إن أمكن) وكتابة ملاحظة في الـ PR تشرح التغييرات ومسارات الملفات الجديدة.

**Relevant files**
- [lib/core/entities/main_account_entity.dart](lib/core/entities/main_account_entity.dart)
- [lib/core/entities/sub_account_entity.dart](lib/core/entities/sub_account_entity.dart)
- [lib/core/entities/sub_account_simple_entity.dart](lib/core/entities/sub_account_simple_entity.dart)
- [lib/core/repositories/interfaces/main_account_repository.dart](lib/core/repositories/interfaces/main_account_repository.dart)
- [lib/core/repositories/interfaces/sub_account_repository.dart](lib/core/repositories/interfaces/sub_account_repository.dart)
- [lib/core/datasources/interfaces/main_account_data_source.dart](lib/core/datasources/interfaces/main_account_data_source.dart)
- [lib/core/datasources/interfaces/sub_account_data_source.dart](lib/core/datasources/interfaces/sub_account_data_source.dart)
- [lib/core/datasources/implementations/main_account_local_data_source_impl.dart](lib/core/datasources/implementations/main_account_local_data_source_impl.dart)
- [lib/core/datasources/implementations/sub_account_local_data_source_impl.dart](lib/core/datasources/implementations/sub_account_local_data_source_impl.dart)
- [lib/core/usecases/main_account_repository_usecases.dart](lib/core/usecases/main_account_repository_usecases.dart)
- [lib/core/usecases/sub_account_repository_usecases.dart](lib/core/usecases/sub_account_repository_usecases.dart)
- [lib/core/tables/main_accounts_table.dart](lib/core/tables/main_accounts_table.dart)
- [lib/core/tables/sub_accounts_table.dart](lib/core/tables/sub_accounts_table.dart)
- [lib/core/enums/main_account_group_enum.dart](lib/core/enums/main_account_group_enum.dart)
- [lib/core/enums/main_account_type_enum.dart](lib/core/enums/main_account_type_enum.dart)
- [lib/core/enums/sub_account_type_enum.dart](lib/core/enums/sub_account_type_enum.dart)

**Verification**
1. تشغيل `flutter analyze` أو `dart analyze` للتحقق من استيرادات مفقودة.
2. تشغيل `flutter test` أو اختبارات المشروع المتوفرة للتأكد أن الـ usecases والمستودعات تعمل.
3. اختبار يدوي للتطبيق (build/run) على المحاكي للتأكد من أن الميزات التي تعتمد على الحسابات تعمل.
4. مراجعة الـ DI: تشغيل سيناريوهات تسجيل/حل الاعتمادية لاكتشاف أية استثناءات.

**Decisions / Assumptions**
- نفترض أن بنية `lib/core` حالياً تحتوي فقط على عقود/تنفيذات خاصة بالحسابات كما تم اكتشافها؛ إذا ظهرت تبعيات مشتركة واسعة يجب إبقاء تلك الأجزاء في `core` بدل النقل.
- نوصي بعمل re-export في `lib/core/accounts.dart` لفترة انتقالية إذا هناك مستورِدون كثيرون يعتمدون على `core` حتى يتم تحديث كل ملفات المشروع وPRs تدريجياً.

**Further Considerations**
1. هل تريد أن أنفذ النقل فعلياً (إنشاء الملفات ونقلها وتحديث الاستيرادات) أم تكتفي بالخطة فقط؟
2. هل تفضل أن أبقي الجداول (`tables`) في `core/tables` كمرجع مشترك أم أن أنقلها أيضاً داخل `features/accounts/tables`؟
3. هل تريد ملف re-export انتقالي داخل `lib/core` بعد النقل لتسهيل التدرج؟


-- End of plan --