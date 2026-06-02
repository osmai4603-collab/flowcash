---
trigger: clean_architecture
description: القيود الصارمة والقواعد الهندسية لبناء أي ميزة (Feature) باستخدام معمارية Clean Architecture (CA)
---

# 🏛️ قيود معمارية Clean Architecture (CA Strict Constraints)

هذا المستند يحدد القواعد والقيود الصارمة التي **يجب** الالتزام بها حرفياً عند بناء أو إعادة هيكلة أي ميزة (Feature) في التطبيق لضمان اتساق الكود، وسهولة اختباره، وقابلية صيانته.

---

## 🚫 1. محظورات عامة (General Prohibitions)

*   **تجاوز الطبقات (Layer Skipping)**: يُمنع منعاً باتاً أن تتواصل طبقة مع طبقة أخرى تتجاوز الطبقة التي تليها مباشرة. (مثال: يمنع تواصل UI مع DataSource مباشرة).
*   **استيرادات خاطئة (Wrong Imports)**:
    *   يُمنع استيراد أي ملف من مجلد `data` أو `presentation` داخل مجلد `domain`.
    *   يُمنع استيراد أي ملف من مجلد `presentation` داخل مجلد `data`.
*   **المنطق في الواجهة (UI Logic)**: يُمنع وضع أي منطق أعمال (Business Logic) أو استدعاءات قواعد بيانات/API داخل الـ UI مباشرة.

---

## 🟢 2. طبقة المجال (Domain Layer) - القلب النابض

هذه الطبقة هي الأنقى، ولا تعتمد على أي مكتبات خارجية (باستثناء `equatable` و `fpdart`).

*   **التواصل (Communication Bounds)**: معزولة تماماً. لا تتحدث مع أي طبقة أخرى (لا تعرف بوجود Data أو Presentation). الطبقات الأخرى هي التي تعتمد عليها وتستدعيها.
*   **نوع البيانات (Data Handled)**: تتعامل حصراً مع الكيانات النظيفة (`Entities`) والأنواع الأساسية (Primitives). يُمنع دخول أي `Model` إليها.

### أ. الكيانات (Entities)
*   **الوراثة**: يجب أن يرث الكائن من `Equatable`.
*   **التعريف**: يجب أن تكون جميع الحقول `final` واستخدام باني `const`.
*   **الدوال**: يجب توفير `props` للمقارنة، ودالة `copyWith` للنسخ المتغير.
*   **المحظورات**: يُمنع منعاً باتاً وجود دوال التحويل (`fromMap`, `toMap`, `fromJson`, `toJson`) في الـ Entity. هذه وظيفة الـ Model.

### ب. واجهات المستودعات (Repository Interfaces)
*   **التعريف**: يجب أن تُعرّف كـ `abstract interface class`.
*   **الإرجاع**: جميع الدوال **يجب** أن تُرجع `Future<Either<Failure, T>>` باستخدام مكتبة `fpdart`.
*   **المحظورات**: يُمنع استخدام الـ Models كنوع للبيانات المُرجعة أو المُرسلة. تعامل فقط مع الـ Entities والأنواع الأساسية (Primitives). للعمليات التي لا ترجع بيانات، استخدم `unit` من `fpdart`.

### ج. حالات الاستخدام (Use Cases)
*   **المسؤولية**: كل Use Case يقوم بمهمة واحدة فقط (Single Responsibility).
*   **الحقن**: يجب حقن واجهة المستودع (Repository Interface) وليس تنفيذه الفعلي.
*   **الدالة الرئيسية**: يجب استخدام دالة `call` لتنفيذ المهمة.

---

## 🔵 3. طبقة البيانات (Data Layer) - المحرك

هذه الطبقة مسؤولة عن جلب وتحويل البيانات التقنية.

*   **التواصل (Communication Bounds)**: تتحدث "للأعلى" مع طبقة الـ `Domain` (لتنفيذ واجهاتها)، وتتحدث "للخارج" مع قواعد البيانات والـ APIs. لا تتحدث أبداً مع طبقة الـ `Presentation`.
*   **نوع البيانات (Data Handled)**: تتعامل مع البيانات التقنية الخام (JSON, Maps) وتُحولها إلى `Models`. ثم **تُجبر** على تحويل هذه الـ `Models` إلى `Entities` قبل تمريرها لطبقة الـ `Domain`.

### أ. النماذج (Models)
*   **الوراثة**: يجب أن يكون `final class` ويرث من الـ Entity المقابل.
*   **التحويل الفطري**: يجب توفير دوال التحويل (`fromMap`, `toMap`).
*   **كلاسات الجداول**: **يُمنع منعاً باتاً** استخدام نصوص ثابتة (Hardcoded Strings) لمفاتيح الـ Map. **يجب** استخدام كلاسات الجداول المركزية من `lib/core/tables/`.

### ب. واجهات مصادر البيانات (DataSource Interfaces)
*   **التعريف**: `abstract interface class`.
*   **الإرجاع**: تُرجع `Future<T>` (Models أو أنواع أساسية)، وليس `Either`.
*   **الأخطاء**: يتم رمي استثناءات (`Exceptions`) صريحة عند الفشل (مثل `ServerException`, `LocalDatabaseException`).

### ج. تنفيذ مصادر البيانات (DataSource Implementations)
*   **الربط**: `implements` للواجهة المقابلة.
*   **البيانات المكثفة**: يجب استخدام `compute` للعمليات الثقيلة (مثل فك تشفير JSON ضخم) لتجنب تجميد الواجهة (UI Blocking).

### د. تنفيذ المستودعات (Repository Implementations)
*   **الربط**: `implements` للواجهة المقابلة في طبقة الـ Domain.
*   **معالجة الأخطاء (Crucial)**: **يجب** تغليف كل عملية بـ `try-catch`.
*   **الاستثناءات إلى فشل**: يجب التقاط الـ `Exceptions` المرمية من الـ DataSource وتحويلها إلى `Failure` (مثال: `LocalDatabaseFailure`) وإرجاعها داخل `left()`.
*   **تحويل البيانات**: تحويل الـ Models القادمة من الـ DataSource إلى Entities قبل إرجاعها داخل `right()`.

---

## 🟠 4. طبقة العرض (Presentation Layer) - واجهة المستخدم

هذه الطبقة مسؤولة عن عرض البيانات والتفاعل مع المستخدم.

*   **التواصل (Communication Bounds)**: تتحدث "للأسفل" مع طبقة الـ `Domain` فقط (عبر استدعاء الـ `Use Cases`). **يُمنع منعاً باتاً** أن تتحدث مع طبقة الـ `Data` (لا `Repositories` ولا `DataSources`).
*   **نوع البيانات (Data Handled)**: تستقبل `Entities` من الـ `Domain` (عبر الـ `State`) لعرضها للمستخدم. وتُرسل مدخلات المستخدم كـ `Entities` أو أنواع أساسية (عبر الأحداث `Events`). لا تعرف شيئاً عن الـ `Models`.

### أ. إدارة الحالة (State Management - BLoC)
*   **الحقن**: يُحقن الـ BLoC/Cubit بحالات الاستخدام (Use Cases) **فقط**. يُمنع حقن الـ Repositories مباشرة.
*   **كلاس الحالة (State Class)**: **يجب** استخدام كلاس حالة واحد موحد (Single State Class) يحتوي على `enum` لتتبع الحالة (Status) بدلاً من استخدام عدة كلاسات فرعية للحالات.
*   **دوال التعديل**: يجب أن تكون دوال تعديل القوائم (`addItem`, `updateItem`, `removeItem`) موجودة داخل كلاس الـ State نفسه، وتستدعى من داخل الـ Bloc باستخدام `emit(state.updateItem(item))`.
*   **إعادة التحميل (No Re-fetching)**: **يُمنع منعاً باتاً** إعادة استدعاء دالة التحميل (Fetch) بعد إتمام عمليات (CRUD). **يجب** تحديث الحالة محلياً.
*   **الرسائل (Localization)**: يُمنع إرسال نصوص ثابتة (Hardcoded Strings) من الـ Bloc للعرض. يجب إرسال حالة النجاح/الفشل، ويقوم الـ UI بعرض النص المترجم المناسب.

### ب. واجهة المستخدم (UI Pages)
*   **طبيعة الصفحة**: يُفضل أن تكون الصفحات `StatelessWidget`.
*   **التعامل مع BLoC**:
    *   استخدم `BlocProvider` لتوفير الـ Bloc للصفحة.
    *   استخدم `BlocBuilder` لإعادة البناء بناءً على `state.status`.
    *   استخدم `BlocListener` للتعامل مع التأثيرات الجانبية (SnackBars, Navigation, Dialogs).
*   **البيانات**: يتعامل الـ UI مع الكيانات (Entities) فقط، ولا يعلم شيئاً عن النماذج (Models).

---

## 💉 5. حقن التبعيات (Dependency Injection)

*   **التسجيل**: يجب تسجيل جميع التبعيات في ملف `_injection.dart` خاص بالميزة، ثم استدعاء دالة التهيئة في `injection_container.dart` الرئيسي.
*   **نوع الحقن**:
    *   DataSources و Repositories و UseCases: تُسجل كـ `LazySingleton`.
    *   Blocs و Cubits: تُسجل كـ `Factory` لضمان الحصول على نسخة جديدة عند فتح الصفحة.
*   **الواجهات**: احرص دائماً على ربط الواجهة (Interface) بتنفيذها (Implementation) عند التسجيل (مثال: `sl.registerLazySingleton<ExampleRepository>(() => ExampleRepositoryImpl(sl()));`).
