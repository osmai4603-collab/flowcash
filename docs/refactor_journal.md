## Plan: إعادة هيكلة صفحة إدخال القيود اليومية

TL;DR - الهدف: استبدال الجدول الحالي بواجهة مكونة من قسمين متتاليين (الجزء العلوي: المدينون، الجزء السفلي: الدائنون). كل قسم يحتوي على قائمة بنود يمكن إضافة/حذفها، كل بند يتضمن: اختيار الحساب، المبلغ، البيان التفصيلي، وزر للحذف. شرط تحقّق: وجود بند واحد على الأقل في كل قسم. التنفيذ يُجرى عبر تعديل الواجهة في `journal_entry_form_dialog.dart` و `journal_item_row_form.dart` مع تحديث البلوك (`journal_entry_form_bloc.dart`) لحفظ قواعد التحقق الجديدة.

**Steps**
1. تحليل قائم: راجع ملفات الواجهة والبلوك الحالية لتحديد نقاط الإدخال (تمت مراجعتها اوليًا). *done*.
2. تصميم الواجهة الجديدة (عرض بصري):
   - استبدال القائمة/الجدول الحالي بقسمين عموديين متتابعين داخل نفس الحوار: "المدينون" فوقًا، "الدائنون" تحتًا.
   - كل قسم يحتوي على زر `+ إضافة بند` يضيف بندًا من نوع القسم (مدين/دائن).
   - بنود كل قسم تعرض كقوائم رأسية من `JournalItemRowForm` معدّلة (عرض معلَّم لنوع البند).
   - بجانب الحقول: زر حذف لكل بند، مع تعطيل الحذف إن أدى لعدد بنود = 0 (ممنوع).
3. تعديلات البلوك (`JournalEntryFormBloc`):
   - فصل قوائم البنود إلى قائمتين في الـ state: `debitItems` و `creditItems` (أو إبقاء `items` مع علامة `type` لكل بند). *يفضل: إضافة `side` في `JournalItemDraft` لتقليل تغييرات منطق الحفظ*.
   - تعديل أحداث: `AddJournalItemField(side)`, `RemoveJournalItemField(side, index)`, `JournalItemFieldChanged(side, index, ...)`.
   - قيد تحقق جديد: عند الحذف لا تسمح بخفض عدد البنود في أي قسم أقل من 1 — إذا حاول المستخدم الحذف الأخير، إظهار رسالة خطأ أو تعطيل الزر.
   - تحديث منطق التوازن: حساب مجموع المدينين ومجموع الدائنين كما هو، والتأكد من أن القيد متوازن قبل الحفظ.
   - تحديث رسالة الخطأ الحالية التي كانت تفترض حد أدنى 2 بنود إجمالي إلى قاعدة "الحد الأدنى: بند واحد في كل قسم".
4. تعديل `JournalItemRowForm` و/أو إنشاء `JournalItemRowFormCompact`:
   - واجهة البند تظل: اختيار الحساب، حقل المبلغ (مُعنوَن بحسب الجانب: "مدين" أو "دائن"), حقل البيان التفصيلي، زر حذف.
   - عند تغيير المبلغ/الحساب/البيان، إرسال حدث يحتوي على `side` و`index`.
   - إزالة أو تعطيل فكرة عمودي الدائن/المدين بنفس السطر — الآن كل بند يظهر حقل مبلغ واحد يتبع نوع القسم.
5. تحديث `journal_entry_form_dialog.dart` (الـ UI الحاوي):
   - إحلال بنائين عموديين (قوائم) داخل `SingleChildScrollView` أو `ListView`: أولًا `Section: المدينون` ثم `Section: الدائنون`.
   - لكل قسم: عنوان، زر `+ إضافة بند`, قائمة البنود (محتوى `JournalItemRowForm`)، ومجموع القسم (مجموع المدينين/الدائنين).
   - في أسفل الحوّار: عرض إجمالي المدينين/الدائنين، حالة التوازن، وزر الحفظ/إلغاء.
6. تحديث آليات الإضافة/الحذف في الواجهة:
   - زر الإضافة يرسل `AddJournalItemField(side)`.
   - زر الحذف يرسل `RemoveJournalItemField(side, index)`، ويتحقق UI من تعطيل الحذف إذا كان القسم يحتوي على بند واحد.
7. تحديث الحفظ والمسار الخلفي (إن لزم):
   - عند تحويل `JournalItemDraft` إلى `JournalItemEntity` للاختزان، احتفظ بـ `side` أو خرّج البنود بنفس الترتيب المطلوب من السيرفر.
   - لا تغيّر توقيع واجهات الاستخدام أو مخازن البيانات إن لم يكن ضرورياً — قم بتحويل داخلي في البلوك/ usecase.
8. اختبارات يدوية وآلية:
   - يدوياً: افتح حوار إنشاء/تعديل قيد، حاول إضافة/حذف بنود في كل قسم، تأكد من عدم السماح بترك قسم فارغ، تحقق من رسائل الخطأ، وتحقق من التوازن والحفظ.
   - آليًا: إضافة اختبارات وحدة للـ bloc: إضافة/حذف بنود لكل قسم، تحقق من الحالة `isBalanced`، ورسائل الخطأ عند محاولات الحذف الممنوعة.
9. توثيق صغير: تحديث README أو ملف الـ docs المناسب يصف السلوك الجديد (واجبات الحقل، حذف مقيد).

**Relevant files**
- [lib/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_bloc.dart](lib/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_bloc.dart)
- [lib/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_event.dart](lib/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_event.dart)
- [lib/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_state.dart](lib/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_state.dart)
- [lib/features/accounts/presentation/pages/journal_entries/journal_entry_form_dialog.dart](lib/features/accounts/presentation/pages/journal_entries/journal_entry_form_dialog.dart)
- [lib/features/accounts/presentation/widgets/journal_item_row_form.dart](lib/features/accounts/presentation/widgets/journal_item_row_form.dart)
- [lib/features/accounts/presentation/widgets/journal_entry_detail_panel.dart](lib/features/accounts/presentation/widgets/journal_entry_detail_panel.dart)

**Verification**
1. واجهة: فتح `JournalEntryFormDialog` وإجراء السيناريوهات: إضافة منصب مدين/دائن، محاولة حذف آخر بند في قسم، التأكد من أن الحفظ لا يسمح بقيد غير متزن.
2. بلوك: وحدة اختبار تغطي: إضافة بند (debit/credit)، حذف بند حتى الحد الأدنى، تغيّر حقل بند واحد، وتحويل وإرسال حدث `Submit` مع توقع نجاح/فشل بناءً على التوازن.
3. تكامل: حفظ قيد متوازن والتأكد من أن البيانات المرسلة للـ usecase تتضمن جانب كل بند بشكل صحيح.

**Decisions / Assumptions**
- أبقي التغيير منطقيًا داخل الـ Bloc قدر الإمكان (وضع جانب `side` في `JournalItemDraft`) لتقليل تغييرات في طبقات التخزين أو الـ usecases.
- واجهة المستخدم ستعرض حقل مبلغ واحد لكل بند (ليس حقلين مدين/دائن في نفس البند).
- أترك زر الحذف مرئيًا لكن معطلًا عندما يكون عدد البنود = 1 في القسم، بدل اظهار رسالة منبثقة عند كل محاولة.

**Further Considerations**
1. RTL: تأكد من محاذاة الأزرار والعناوين لتنسيق عربي واضح.
2. Accessibility: اجعل أزرار الإضافة/الحذف قابلة للوصول مع تسميات `semanticsLabel` بالعربية.
3. UX: هل تريد الربط التلقائي بين مجموعي المدينين والدائنين (اقتراحات لملء الفرق)؟ ممكن إضافة لاحقًا كتحسين.


