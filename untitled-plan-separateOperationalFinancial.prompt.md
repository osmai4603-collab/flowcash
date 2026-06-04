## Plan: فصل العمليات التشغيلية عن المالية

TL;DR - تقسيم التنفيذ إلى مراحل متسلسلة يضمن فصلًا واضحًا بين البيانات المالية والتشغيلية، مع معالجة علاقات الحسابات والأشخاص بصورة منفصلة.

### المرحلة 1: الجرد والتصنيف
- مهمة 1.1: راجع جميع جداول `lib/core/tables/*.dart` وحدد ما إذا كانت تابعة للمجال المالي أو المجال التشغيلي.
- مهمة 1.2: راجع الكيانات في `lib/core/entities/*.dart` و `lib/features/inventory/domain/entities/*.dart` وقم بتصنيفها حسب المجال.
- مهمة 1.3: صنف الجداول إلى ثلاث مجموعات:
  * المالية: `journal_entries`, `journal_items`, `main_accounts`, `sub_accounts`.
  * التشغيل/المخزون: `financial_bonds`, `financial_transactions`, `inventory_transactions`, `inventories`, `warehouse_values`, `inventory_batches`, `inventory_transaction_orders`, `goods_costs`, `opening_quantities`, `bills`.
  * المراجع المشتركة: `currencies`, `accounting_periods`, `warehouses`, `hints`, `persons`.
- مهمة 1.4: وثق المتطلبات الجديدة للعلاقة بين الأشخاص والحسابات الفرعية: احذف `person_id` من `sub_accounts` واجعل جدول `persons` يحتفظ بعمودي `receivable_account_id` و `payable_account_id` مرجعًا إلى `sub_accounts(account_id)`.

### المرحلة 2: تحديد بنية البيانات الهدف
- مهمة 2.1: حدد الحدود المفهومية لكل مجال:
  * المجال المالي: قيود دفتر يومية، حركات مالية، سندات، أصول، حسابات.
  * المجال التشغيلي: فواتير، بنود فاتورة، مخزون، دفعات، تكاليف، حركة مخزون.
- مهمة 2.2: قرر وضع جدول `bills` كجدول تشغيل رئيسي، مع ربط مالي مرجعي فقط عبر `journal_entry_id` أو حقل مماثل.
- مهمة 2.3: قرر بنية جدول `persons` الجديدة المبنية على نموذج `contacts` مع الحقول:
  * `person_id`
  * `person_name`
  * `person_type`
  * `receivable_account_id`
  * `payable_account_id`
  * `phone_number`
  * `email`
  * `created_at`
- مهمة 2.4: قرر إزالة أي حقول حسابية مباشرة في الجداول التشغيلية التي لها `debtor_id`, `creditor_id`, وأسعار صرف.

### المرحلة 3: تحديث الجداول التشغيلية
- مهمة 3.1: حدِّد الجداول التي يجب تنظيفها من الحقول المالية المباشرة:
  * `bills`
  * `goods_costs`
  * `inventory_transactions`
  * `opening_quantities`
- مهمة 3.2: احذف الحقول التالية من الجداول التشغيلية:
  * `debtor_id`
  * `creditor_id`
  * `sub_debtor_ex_price`
  * `sub_creditor_ex_price`
  * `main_debtor_ex_price`
  * `main_creditor_ex_price`
- مهمة 3.3: أضف حقلًا واحدًا مرجعيًا إلى `journal_entries` أو `journal_entry_id` في الجداول التشغيلية التي تحتاج الربط المالي المركزي.
- مهمة 3.4: ضَمِن أن `inventory_transactions_orders`, `bill_orders`, `inventory_batches`, و `warehouse_default_values` تبقى تشغليًا فقط.

### المرحلة 4: إعادة تنظيم العلاقات بين الأشخاص والحسابات
- مهمة 4.1: عدّل `sub_accounts` لإزالة `person_id` من الحقول.
- مهمة 4.2: وسّع `persons` (أو جدول `contacts`) ليحتوي على:
  * `receivable_account_id INTEGER REFERENCES sub_accounts(account_id)`
  * `payable_account_id INTEGER REFERENCES sub_accounts(account_id)`
- مهمة 4.3: اجعل العلاقات بين الأشخاص والحسابات الفرعية غير مباشرة، بحيث يكون `persons` هو الطرف الأساسي للعلاقة ويشير إلى الحسابات بدلاً من العكس.
- مهمة 4.4: احتفظ بجدول `persons` كجدول مرجعي عام للمستخدمين والعملاء والموردين وغيرها.

### المرحلة 5: مراجعة الجداول المالية
- مهمة 5.1: تأكيد أن الجداول المالية تحمل فقط البيانات المحاسبية:
  * `journal_entries`
  * `journal_items`
  * `main_accounts`
  * `sub_accounts`
- مهمة 5.2: أدخل تصنيفًا أو حقلًا إضافيًا في الجداول المالية إن لزم الأمر مثل `domain_type` أو `bond_domain` لتوضيح طبيعة السجل.
- مهمة 5.3: أبقِ `main_accounts` كجدول محاسبي رئيسي، لكن أضف حقل `account_domain` لتصنيف الحسابات بين:
  * حسابات مالية أساسية
  * حسابات تكلفة تشغيلية / مخزون

### المرحلة 6: ضبط المراجع المشتركة والتوافق
- مهمة 6.1: تحقق من أن المراجع التالية تبقى مشتركة، ولا تُغير هيكلها إلا إذا احتجنا:
  * `currencies`
  * `accounting_periods`
  * `warehouses`
  * `hints`
- مهمة 6.2: إذا احتاج `persons` إلى حقول إضافية مثل `phone_number` أو `email`, فاعتبره جدول جهات اتصال وليس جدول علاقات محاسبية مباشرة.
- مهمة 6.3: راجع تدفقات البيانات بين الجداول المشتركة والمجالات الثلاثة للتأكد من عدم وجود تداخل غير مرغوب.

### المرحلة 7: المراجعة والتوثيق
- مهمة 7.1: صنّف كل جدول إلى المجال المناسب في المستند.
- مهمة 7.2: أعد التوثيق في `docs/edits.md` أو ملف الخطة التوثيقية قبل البدء في التنفيذ.
- مهمة 7.3: راجع `lib/core/services/sqlite_default_data.dart` و `lib/core/services/sqlite_service.dart` للتأكد من أن عمليات الإنشاء والبيانات الافتراضية تتوافق مع الفصل الجديد.

### المرحلة 8: التحقق النهائي
- مهمة 8.1: افحص أن الجداول التشغيلية لا تحتوي على حقول مالية مباشرة بعد التعديلات.
- مهمة 8.2: افحص أن الجداول المالية تستخدم فقط القيود والبنود المالية.
- مهمة 8.3: تحقق من أن `persons` يربط إلى `sub_accounts` عبر حقلي `receivable_account_id` و `payable_account_id`.
- مهمة 8.4: تحقق من أن أي تكامل تشغيل-مالي يتم عبر مرجع واحد إلى `journal_entries` وليس عبر عدة حقول حسابية مختلفة.

**Relevant files**
- `lib/core/tables/financial_bonds_table.dart`
- `lib/core/tables/financial_transactions_table.dart`
- `lib/core/tables/bills_table.dart`
- `lib/core/tables/sub_accounts_table.dart`
- `lib/core/tables/persons_table.dart`
- `lib/core/tables/inventory_transactions_table.dart`
- `lib/core/tables/inventories_table.dart`
- `lib/core/entities/financial_bond_entity.dart`
- `lib/core/entities/financial_transaction_entity.dart`
- `lib/core/entities/bill_entity.dart`
- `lib/features/inventory/domain/entities/inventory_entity.dart`
- `lib/features/injection_container.dart`
- `lib/core/services/sqlite_default_data.dart`
- `lib/core/services/sqlite_service.dart`

**Verification**
1. افحص قائمة الجداول في قاعدة البيانات الحالية وتأكد من تصنيفها إلى مالي/تشغيلي.
2. تأكد من إزالة `person_id` من `sub_accounts` وأن `persons` يحتوي على `receivable_account_id` و `payable_account_id`.
3. تحقق من أن الجداول التشغيلية لا تحتوي على `debtor_id`, `creditor_id`, أو أسعار صرف مباشرة.
4. راجع ملفات خدمة SQLite للتأكد من اتساق إنشائها مع التصميم الجديد.

**Decisions**
- الفصل يستند إلى فصل البيانات والمراجع أكثر من فصل مجرد الأكواد.
- `bills` و `goods_costs` تتحول إلى جداول تشغيلية مع رابط مالي مركزي وحيد.
- `persons` يصبح جدول جهات اتصال مرتبطًا بحسابات القبض والدفع، بدلاً من أن يكون طرفًا في الحسابات الفرعية.
