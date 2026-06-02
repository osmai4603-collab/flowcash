---
trigger: model_decision
description: القواعد الخاصة بإدارة الحالة (State Management) والتعامل مع الـ Bloc و Cubit و Provider
---

# 🧠 State Management Rules (قواعد إدارة الحالة)

هذا المستند يحدد القواعد الصارمة لإدارة الحالة (State Management) داخل التطبيق، لضمان اتباع مبادئ Clean Architecture وفصل المسؤوليات.

---

## 🏗️ 1. حقن التبعيات (Dependency Injection)

* **يجب** عند إنشاء أي كلاس لإدارة الحالة (سواء كان `Bloc` أو `Cubit` أو `Provider`) أن يتم حقنه بـ **حالات الاستخدام (Use Cases)** حصراً.
* **يمنع منعاً باتاً** حقن كلاسات إدارة الحالة بـ **المستودعات (Repositories)** مباشرة.
* تتمثل الوظيفة الأساسية للـ Bloc/Cubit في تنسيق تدفق البيانات واستدعاء الـ Use Cases المناسبة، وليس التواصل المباشر مع طبقة البيانات.

### ✅ الطريقة الصحيحة (Correct)

```dart
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthInitial());
}
```

### ❌ الطريقة الخاطئة (Incorrect)

```dart
// يمنع حقن الـ Repository مباشرة في الـ Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());
}
```

## 📝 2. معايير النصوص والرسائل (Text and Messaging Standards)

* **يمنع منعاً باتاً** كتابة أي نصوص مباشرة (Hardcoded Strings) داخل الـ `Bloc` أو `Cubit` للرسائل التحذيرية، رسائل النجاح، أو رسائل الفشل.
* **يجب** أن يتم التعامل مع عرض الرسائل في طبقة الواجهات (View) حصراً باستخدام كائن الـ `localization`.
* الـ `Bloc` مسؤول فقط عن إرسال الحالة (State) أو نوع الخطأ، والـ UI يقرر النص المناسب للترجمة.

### ✅ الطريقة الصحيحة (Correct)

```dart
// في الـ Bloc/Cubit (إرسال حالة نجاح مجردة)
emit(const ProductUpdateSuccess());

// في الـ UI (استخدام الـ localization لعرض الرسالة)
if (state is ProductUpdateSuccess) {
  showSuccessSnackBar(context, localization.productUpdatedSuccessfully);
}
```

### ❌ الطريقة الخاطئة (Incorrect)

```dart
// يمنع إرسال نص ثابت أو مترجم من داخل الـ Bloc
emit(const ProductUpdateFailure(message: "حدث خطأ أثناء التحديث"));
```

## 🔄 3. إدارة البيانات والتحديث المحلي (Data Management and Local Updates)

* **يجب** تحميل البيانات من الخادم (Server) مرة واحدة فقط عند الحاجة (مثلاً عند فتح الصفحة أو تحميل أول صفحة في الـ Pagination).
* **يمنع منعاً باتاً** إعادة استدعاء دالة التحميل (Fetch/Load) بعد إتمام عمليات الإضافة، التحديث، أو الحذف (CRUD Operations).
* **يجب** تحديث الحالة (State) محلياً داخل الـ `Bloc` أو `Cubit` باستخدام الكائن المحدث أو المضاف العائد من الـ Use Case، لضمان استجابة فورية للواجهة (Instant UI update) وتقليل الضغط على الخادم.

### ✅ الطريقة الصحيحة (Correct)

```dart
// بعد نجاح العملية، نقوم بتحديث القائمة الحالية في الذاكرة بدلاً من إعادة جلبها
final updatedList = List<Product>.from(state.products);
final index = updatedList.indexWhere((p) => p.id == updatedProduct.id);
if (index != -1) {
  updatedList[index] = updatedProduct;
}
emit(state.copyWith(products: updatedList));
```

### ❌ الطريقة الخاطئة (Incorrect)

```dart
// يمنع منعاً باتاً إعادة تحميل القائمة بالكامل بعد كل عملية تعديل بسيطة
await updateProductUseCase(product);
add(const FetchProductsEvent()); // خطأ: سيقوم بطلب الشبكة مرة أخرى دون داعٍ
```

## 🧱 4. فصل معالجة البيانات عن المنطق (Separation of Data Handling from Logic)

*   **يجب** تفويض مسؤولية تعديل القوائم والبيانات (مثل `addItem`, `updateItem`, `removeItem`) إلى كلاس الحالة (`State`) نفسه عبر دوال مخصصة.
*   يهدف ذلك إلى جعل الـ `Bloc` أو `Cubit` مجرد "منظم" (Controller/Orchestrator) للتدفق، بينما يتولى الـ `State` مسؤولية سلامة البيانات وتعديلها محلياً.
*   يتماشى هذا مع مبدأ **Liskov Substitution (L in SOLID)** عبر تقليل الحاجة للتحقق المستمر من نوع الحالة (`if state is Loaded`)؛ حيث يفضل استخدام كلاس حالة موحد (Single State Class) يعتمد على `enums` لإدارة الحالات المختلفة، مما يسمح باستبدال الحالات والتعامل مع البيانات بسلاسة.

### ✅ الطريقة الصحيحة (Correct)
```dart
// داخل كلاس الـ State (تعديل البيانات داخلياً)
CatalogState addItem(ProductEntity item) {
  return copyWith(
    items: [item, ...items],
    status: CatalogStatus.success,
  );
}

// داخل الـ Bloc (استدعاء التعديل من الـ State)
on<AddProductEvent>((event, emit) async {
  final result = await _addProductUseCase(event.product);
  result.fold(
    (f) => emit(state.toError(f.message)),
    (newProduct) => emit(state.addItem(newProduct)),
  );
});
```

### ❌ الطريقة الخاطئة (Incorrect)
```dart
// تكرار منطق تعديل القوائم (List Manipulation) داخل الـ Bloc يجعله متضخماً وصعب الاختبار
final updatedList = List<Product>.from(state.items)..add(newItem);
emit(state.copyWith(items: updatedList));
```

---

> [!IMPORTANT]
> الالتزام بهذه القواعد يضمن استقلالية طبقة العرض (Presentation Layer) عن تفاصيل تنفيذ طبقة البيانات، ويسهل عملية الترجمة (Localization)، ويحسن أداء التطبيق، ويجعل الكود أكثر نظافة واتباعاً لمعايير SOLID.

