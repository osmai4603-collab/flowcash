---
name: إعادة هيكلة صفحة (Page Refactoring to Clean Architecture + BLoC)
description: تحويل صفحة Flutter ضخمة (StatefulWidget مع منطق أعمال مخلوط) إلى بنية نظيفة متعددة الطبقات باستخدام Clean Architecture لهيكلة الملفات و BLoC لإدارة الحالة.
---

# مهارة إعادة هيكلة صفحة إلى Clean Architecture + BLoC

تحويل أي صفحة Flutter تحتوي على منطق أعمال وبيانات مخلوطة داخل الواجهة (StatefulWidget ضخم) إلى بنية نظيفة قابلة للاختبار والصيانة وإعادة الاستخدام.

> [!IMPORTANT]
> هذه المهارة هي مهارة **تنسيقية عليا** (Orchestration Skill). تقوم بتنسيق استدعاء المهارات الفرعية الأخرى (Entity، Model، Repository Interface، Repository Impl، DataSource Interface، DataSource Impl، Use Case) بالترتيب الصحيح. **يجب قراءة كل مهارة فرعية والالتزام بقواعدها الصارمة عند تنفيذ الخطوة المقابلة لها.**

---

## 📋 المرحلة الأولى: التحليل (Analysis)

قبل كتابة أي كود جديد، يتم تفكيك الصفحة الحالية وفهم كل مكوناتها. **يجب توثيق نتائج هذه المرحلة في خطة التنفيذ (Implementation Plan) قبل البدء بالكتابة.**

### 1. تشريح الحالة (State Dissection)

* استخراج جميع المتغيرات المعرفة في `State` (متحكمات النصوص، قوائم، متغيرات علم، كائنات مختارة).
* رصد كل استخدام لـ `setState` وتحديد سبب الاستدعاء.
* تحديد الحالات الضمنية: تحميل، خطأ، نجاح (ظهور/اختفاء مؤشر تحميل، حوارات).

### 2. استخلاص الأحداث (Event Extraction)

* تحديد كل ما يمكن أن يفعله المستخدم: نقر أزرار، تغيير نصوص، اختيار من قوائم، سحب للتحديث.
* تحديد أحداث النظام: تحميل أولي للبيانات، استقبال بيانات من صفحة أخرى.

### 3. عزل منطق الأعمال (Business Logic Isolation)

* ماذا يحدث عند كل حدث؟ (تحقق من صحة، عمليات حسابية، تسلسل استدعاءات).
* تحديد قواعد العمل الحقيقية التي ليست مجرد استدعاء مباشر لقاعدة البيانات.

### 4. جرد مصادر البيانات والخدمات (Data Sources & Services)

* الوصول المباشر لقاعدة البيانات (`insert`, `update`, `query`).
* استدعاءات API (`http`, `dio`).
* خدمات المنصة (كاميرا، باركود، GPS، إشعارات).
* الاعتماد على كائنات عامة (global singletons).

### 5. تصنيف المكونات إلى طبقات (Layer Mapping)

| المكون المكتشف | الطبقة الجديدة |
|---|---|
| `TextEditingController`، بناء `Widget`، أي شيء مرئي | **Presentation (UI + BLoC)** |
| التحقق من صحة البيانات، قواعد العمل، تسلسل العمليات | **Domain (Use Cases)** |
| استدعاء قاعدة البيانات، API، الخدمات الخارجية | **Data (DataSources + Repository Impl)** |
| الكائنات الجوهرية (Product, User, Order) | **Domain (Entities)** |
| تحويل البيانات (`fromMap`/`toMap`/`fromJson`/`toJson`) | **Data (Models)** |

### 6. صياغة الأحداث والحالات (Events & States Definition)

بناء جدول واضح قبل كتابة أي كود:

* **الأحداث (Events)**: تمثل كل ما يمكن أن يطلبه المستخدم أو النظام.
* **الحالات (States)**: كلاس حالة **واحد موحد** يحتوي `enum` لتتبع الحالة (وليس كلاسات فرعية).

---

## 🏗️ المرحلة الثانية: التنفيذ (Implementation)

يتم البناء من الداخل إلى الخارج، بدءاً من طبقة المجال (Domain).

### الخطوة 1: إنشاء هيكل مجلدات الميزة

```
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   │   ├── [feature]_local_data_source.dart       ← الواجهة
│   │   └── [feature]_local_data_source_impl.dart   ← التنفيذ
│   ├── models/
│   │   └── [entity]_model.dart
│   └── repositories/
│       └── [feature]_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── [entity]_entity.dart
│   ├── repositories/
│   │   └── [feature]_repository.dart               ← الواجهة المجردة
│   └── usecases/
│       ├── get_[entity]s_use_case.dart
│       ├── add_[entity]_use_case.dart
│       ├── update_[entity]_use_case.dart
│       └── delete_[entity]_use_case.dart
├── presentation/
│   ├── bloc/
│   │   └── [feature]/
│   │       ├── [feature]_bloc.dart
│   │       ├── [feature]_event.dart
│   │       └── [feature]_state.dart
│   └── pages/
│       └── [feature]_page.dart
└── [feature]_injection.dart
```

### الخطوة 2: بناء طبقة المجال (Domain Layer)

> [!IMPORTANT]
> **يجب قراءة والالتزام بقواعد المهارات التالية:**
> * [مهارة بناء الكائنات (Entity Development)](file:///.agent/skills/add_entity/SKILL.md)
> * [مهارة إضافة واجهة مستودع (Repository Interface Development)](file:///.agent/skills/add_repository_interface/SKILL.md)
> * [مهارة إضافة حالة استخدام (Use Case Development)](file:///.agent/skills/add_use_case/SKILL.md)

#### 2.1 إنشاء Entities

* نقل خصائص الكائنات الجوهرية إلى كلاسات ترث من `Equatable`.
* جميع الحقول `final` مع باني `const`.
* يجب تعريف `props` و `copyWith`.
* **يمنع**: `fromMap`/`toMap` داخل الـ Entity.

#### 2.2 كتابة واجهة Repository

* تعريف كـ `abstract interface class`.
* جميع الدوال ترجع `Future<Either<Failure, T>>` باستخدام `fpdart`.
* استخدام `unit` من `fpdart` للعمليات التي لا ترجع بيانات.
* **يمنع**: استخدام Models في الواجهة، فقط Entities والأنواع الأساسية.

#### 2.3 كتابة Use Cases

* كل Use Case مسؤول عن مهمة واحدة فقط (SRP).
* يحقن واجهة Repository (وليس التنفيذ) عبر الـ constructor كـ `final` و `private`.
* الدالة الرئيسية `call()` ترجع `Future<Either<Failure, T>>`.

### الخطوة 3: بناء طبقة البيانات (Data Layer)

> [!IMPORTANT]
> **يجب قراءة والالتزام بقواعد المهارات التالية:**
> * [مهارة تطوير الموديلات (Model Development)](file:///.agent/skills/add_model/SKILL.md)
> * [مهارة إضافة واجهة مصدر بيانات (Data Source Interface Development)](file:///.agent/skills/add_data_source_interface/SKILL.md)
> * [مهارة إضافة تنفيذ مصدر بيانات (Data Source Implementation Development)](file:///.agent/skills/add_data_source_implementation/SKILL.md)
> * [مهارة إضافة تنفيذ مستودع (Repository Implementation Development)](file:///.agent/skills/add_repository_implementation/SKILL.md)

#### 3.1 إنشاء Models

* `final class` يرث من الـ Entity المقابل.
* باني `const` يستدعي `super(...)`.
* **`fromMap`**: يستخدم كلاسات الجداول المركزية من `lib/core/tables/`. **يمنع** استخدام نصوص مباشرة للمفاتيح.
* **`toMap`**: يستخدم نفس كلاسات الجداول.
* **`copyWith`**: ترجع نوع الـ Model.

#### 3.2 إنشاء DataSource Interface

* `abstract interface class`.
* الدوال ترجع `Future<T>` (وليس `Either`).
* الأخطاء تُرمى كـ `Exceptions` صريحة (`LocalDatabaseException`، `ServerException`).

#### 3.3 إنشاء DataSource Implementation

* `implements` الواجهة المقابلة.
* يحقن `DatabaseService` أو `ApiService` عبر الـ constructor.
* يستخدم كلاسات الجداول المركزية.
* للعمليات الثقيلة، يستخدم `compute` لنقلها إلى Isolate منفصل.

#### 3.4 تنفيذ Repository

* `implements` واجهة Repository من طبقة Domain.
* يحقن DataSource عبر الـ constructor.
* **قاعدة صارمة**: كل دالة تستخدم `try-catch`.
* يلتقط `Exceptions` ويحولها إلى `Failure` المناسب.
* النجاح → `right(data)`، الفشل → `left(failure)`.

### الخطوة 4: تصميم BLoC

> [!IMPORTANT]
> **يجب الالتزام بقواعد [إدارة الحالة](file:///.agent/rules/state_management.md) الموجودة في قواعد المشروع.**

#### 4.1 تعريف Events (`[feature]_event.dart`)

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/[entity]_entity.dart';

/// الكلاس الأساسي لأحداث [Feature].
sealed class [Feature]Event extends Equatable {
  const [Feature]Event();

  @override
  List<Object?> get props => [];
}

/// حدث تحميل البيانات.
final class Load[Feature] extends [Feature]Event {
  // البارامترات المطلوبة للتحميل (إن وجدت)
  const Load[Feature]();
}

/// حدث إضافة عنصر جديد.
final class Add[Entity] extends [Feature]Event {
  final [Entity]Entity [entity];

  const Add[Entity](this.[entity]);

  @override
  List<Object?> get props => [[entity]];
}

/// حدث تحديث عنصر.
final class Update[Entity] extends [Feature]Event {
  final [Entity]Entity old[Entity];
  final [Entity]Entity new[Entity];

  const Update[Entity]({required this.old[Entity], required this.new[Entity]});

  @override
  List<Object?> get props => [old[Entity], new[Entity]];
}

/// حدث حذف عنصر.
final class Delete[Entity] extends [Feature]Event {
  final [Entity]Entity [entity];

  const Delete[Entity](this.[entity]);

  @override
  List<Object?> get props => [[entity]];
}
```

**قواعد الأحداث:**

* الكلاس الأب يكون `sealed class` يرث من `Equatable`.
* كل حدث هو `final class`.
* يحمل فقط البيانات المطلوبة لتنفيذ العملية.

#### 4.2 تعريف State (`[feature]_state.dart`)

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/[entity]_entity.dart';

/// حالات [Feature].
enum [Feature]Status { initial, loading, success, failure }

/// كلاس الحالة الموحد لـ [Feature].
final class [Feature]State extends Equatable {
  final [Feature]Status status;
  final List<[Entity]Entity> items;
  final String? errorMessage;

  const [Feature]State({
    this.status = [Feature]Status.initial,
    this.items = const [],
    this.errorMessage,
  });

  [Feature]State copyWith({
    [Feature]Status? status,
    List<[Entity]Entity>? items,
    String? errorMessage,
  }) {
    return [Feature]State(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// إضافة عنصر للقائمة محلياً.
  [Feature]State addItem([Entity]Entity item) {
    return copyWith(
      items: [item, ...items],
      status: [Feature]Status.success,
    );
  }

  /// تحديث عنصر في القائمة محلياً.
  [Feature]State updateItem([Entity]Entity item) {
    final updatedList = List<[Entity]Entity>.from(items);
    final index = updatedList.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      updatedList[index] = item;
    }
    return copyWith(
      items: updatedList,
      status: [Feature]Status.success,
    );
  }

  /// حذف عنصر من القائمة محلياً.
  [Feature]State removeItem(int id) {
    final updatedList = List<[Entity]Entity>.from(items)
      ..removeWhere((e) => e.id == id);
    return copyWith(
      items: updatedList,
      status: [Feature]Status.success,
    );
  }

  /// تحويل الحالة إلى حالة خطأ.
  [Feature]State toError(String message) {
    return copyWith(
      status: [Feature]Status.failure,
      errorMessage: message,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
```

**قواعد الحالة الصارمة:**

* **كلاس واحد موحد** (وليس كلاسات فرعية): يستخدم `enum` لتتبع الحالة (`initial`, `loading`, `success`, `failure`).
* الكلاس `final class` يرث من `Equatable`.
* جميع الحقول `final`.
* يجب تعريف `copyWith` و `props`.
* **دوال تعديل البيانات تُعرَّف في الـ State وليس في الـ Bloc**: (`addItem`, `updateItem`, `removeItem`, `toError`).
* **يمنع**: تعديل القوائم مباشرة داخل الـ Bloc.

#### 4.3 كتابة BLoC (`[feature]_bloc.dart`)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_[entity]s_use_case.dart';
import '../../../domain/usecases/add_[entity]_use_case.dart';
import '../../../domain/usecases/update_[entity]_use_case.dart';
import '../../../domain/usecases/delete_[entity]_use_case.dart';
import '[feature]_event.dart';
import '[feature]_state.dart';

class [Feature]Bloc extends Bloc<[Feature]Event, [Feature]State> {
  final Get[Entity]sUseCase _get[Entity]sUseCase;
  final Add[Entity]UseCase _add[Entity]UseCase;
  final Update[Entity]UseCase _update[Entity]UseCase;
  final Delete[Entity]UseCase _delete[Entity]UseCase;

  [Feature]Bloc({
    required Get[Entity]sUseCase get[Entity]sUseCase,
    required Add[Entity]UseCase add[Entity]UseCase,
    required Update[Entity]UseCase update[Entity]UseCase,
    required Delete[Entity]UseCase delete[Entity]UseCase,
  })  : _get[Entity]sUseCase = get[Entity]sUseCase,
        _add[Entity]UseCase = add[Entity]UseCase,
        _update[Entity]UseCase = update[Entity]UseCase,
        _delete[Entity]UseCase = delete[Entity]UseCase,
        super(const [Feature]State()) {
    on<Load[Feature]>(_onLoad);
    on<Add[Entity]>(_onAdd);
    on<Update[Entity]>(_onUpdate);
    on<Delete[Entity]>(_onDelete);
  }

  Future<void> _onLoad(Load[Feature] event, Emitter<[Feature]State> emit) async {
    emit(state.copyWith(status: [Feature]Status.loading));
    final result = await _get[Entity]sUseCase(/* params */);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (items) => emit(state.copyWith(
        status: [Feature]Status.success,
        items: items,
      )),
    );
  }

  Future<void> _onAdd(Add[Entity] event, Emitter<[Feature]State> emit) async {
    emit(state.copyWith(status: [Feature]Status.loading));
    final result = await _add[Entity]UseCase(event.[entity]);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (newId) {
        final newItem = event.[entity].copyWith(id: newId);
        emit(state.addItem(newItem));
      },
    );
  }

  Future<void> _onUpdate(Update[Entity] event, Emitter<[Feature]State> emit) async {
    emit(state.copyWith(status: [Feature]Status.loading));
    final result = await _update[Entity]UseCase(
      old[Entity]: event.old[Entity],
      new[Entity]: event.new[Entity],
    );
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (_) => emit(state.updateItem(event.new[Entity])),
    );
  }

  Future<void> _onDelete(Delete[Entity] event, Emitter<[Feature]State> emit) async {
    emit(state.copyWith(status: [Feature]Status.loading));
    final result = await _delete[Entity]UseCase(event.[entity]);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (_) => emit(state.removeItem(event.[entity].id)),
    );
  }
}
```

**قواعد الـ BLoC الصارمة:**

* **يحقن Use Cases حصراً** (وليس Repositories مباشرة).
* كل `on<Event>` يرتبط بمعالج خاص (`_onXxx`).
* يبدأ بإرسال `loading`، ثم يستدعي الـ Use Case، ثم `fold` لمعالجة النتيجة.
* **يمنع**: كتابة نصوص ثابتة للرسائل. الـ UI هو المسؤول عن الترجمة.
* **يمنع**: إعادة تحميل القائمة بالكامل بعد CRUD. يجب تحديث الحالة محلياً عبر دوال الـ State.
* **يمنع**: تعديل القوائم مباشرة في الـ Bloc. يجب استخدام `state.addItem()` / `state.updateItem()` / `state.removeItem()`.

### الخطوة 5: إعادة بناء واجهة المستخدم (Presentation Layer)

#### 5.1 صفحة التغليف (Wrapper Page)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashing/injection_container.dart';
import '../bloc/[feature]/[feature]_bloc.dart';
import '../bloc/[feature]/[feature]_event.dart';

class [Feature]Page extends StatelessWidget {
  const [Feature]Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<[Feature]Bloc>()..add(const Load[Feature]()),
      child: const [Feature]View(),
    );
  }
}
```

#### 5.2 واجهة العرض (View)

```dart
class [Feature]View extends StatelessWidget {
  const [Feature]View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const fluent.Text('...')),
      body: BlocConsumer<[Feature]Bloc, [Feature]State>(
        listener: (context, state) {
          // التأثيرات الجانبية: SnackBar، تنقل، إغلاق حوار
          if (state.status == [Feature]Status.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: fluent.Text(state.errorMessage ?? '')),
            );
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case [Feature]Status.initial:
            case [Feature]Status.loading:
              return const Center(child: CircularProgressIndicator());
            case [Feature]Status.failure:
            case [Feature]Status.success:
              return _buildContent(context, state);
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, [Feature]State state) {
    // بناء الواجهة بناءً على البيانات في الحالة
    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return ListTile(
          title: fluent.Text(item.toString()),
        );
      },
    );
  }
}
```

**قواعد الواجهة:**

* **`BlocProvider`**: يُنشئ في صفحة التغليف (Wrapper) باستخدام `sl<Bloc>()`.
* **`BlocBuilder`**: لإعادة بناء الواجهة بناءً على الحالة. يستخدم `switch` على `state.status`.
* **`BlocListener`**: للتأثيرات الجانبية فقط (SnackBar، تنقل، إغلاق حوار).
* **`BlocConsumer`**: عند الحاجة لكليهما معاً.
* ربط الأحداث: `context.read<[Feature]Bloc>().add(Event)`.
* **يمنع**: أي منطق أعمال في الواجهة. إذا وجدت `if (state.status == ...)` فأنت في المسار الصحيح؛ أما إذا بدأت تحسب قيماً فتوقف فوراً.
* **يمنع**: كتابة نصوص ثابتة في الـ Bloc. الواجهة تستخدم `localization` للنصوص.

### الخطوة 6: حقن التبعيات (Dependency Injection)

#### 6.1 إنشاء ملف الحقن (`[feature]_injection.dart`)

```dart
import 'package:get_it/get_it.dart';

// Data Sources
import 'data/datasources/[feature]_local_data_source.dart';
import 'data/datasources/[feature]_local_data_source_impl.dart';

// Repositories
import 'data/repositories/[feature]_repository_impl.dart';
import 'domain/repositories/[feature]_repository.dart';

// Use Cases
import 'domain/usecases/get_[entity]s_use_case.dart';
import 'domain/usecases/add_[entity]_use_case.dart';
import 'domain/usecases/update_[entity]_use_case.dart';
import 'domain/usecases/delete_[entity]_use_case.dart';

// Blocs
import 'presentation/bloc/[feature]/[feature]_bloc.dart';

void init[Feature]Feature(GetIt sl) {
  //============================================================
  // Data Source
  //============================================================
  sl.registerLazySingleton<[Feature]LocalDataSource>(
    () => [Feature]LocalDataSourceImpl(sl()),
  );

  //============================================================
  // Repository
  //============================================================
  sl.registerLazySingleton<[Feature]Repository>(
    () => [Feature]RepositoryImpl(sl()),
  );

  //============================================================
  // Use Cases
  //============================================================
  sl.registerLazySingleton(() => Get[Entity]sUseCase(sl()));
  sl.registerLazySingleton(() => Add[Entity]UseCase(sl()));
  sl.registerLazySingleton(() => Update[Entity]UseCase(sl()));
  sl.registerLazySingleton(() => Delete[Entity]UseCase(sl()));

  //============================================================
  // Blocs
  //============================================================
  sl.registerFactory(
    () => [Feature]Bloc(
      get[Entity]sUseCase: sl(),
      add[Entity]UseCase: sl(),
      update[Entity]UseCase: sl(),
      delete[Entity]UseCase: sl(),
    ),
  );
}
```

#### 6.2 التسجيل في الحاوية الرئيسية (`injection_container.dart`)

```dart
// إضافة الاستيراد
import 'package:cashing/features/[feature]/[feature]_injection.dart';

// إضافة الاستدعاء داخل initDependencies()
init[Feature]Feature(sl);
```

**قواعد حقن التبعيات:**

* **DataSource و Repository**: يُسجلان كـ `LazySingleton`.
* **Use Cases**: تُسجل كـ `LazySingleton`.
* **Bloc**: يُسجل كـ `Factory` (نسخة جديدة كل مرة).
* الحقن يتم بالواجهات (Interfaces) وليس بالتنفيذات.
* يُستدعى `init[Feature]Feature(sl)` في `injection_container.dart`.

---

## ✅ قائمة المراجعة النهائية (Final Checklist)

عند الانتهاء من إعادة الهيكلة، تأكد من:

- [ ] **طبقة Domain** لا تستورد أي شيء من `data/` أو `presentation/`.
- [ ] **طبقة Data** لا تستورد أي شيء من `presentation/`.
- [ ] كل **Entity** يرث من `Equatable` ويحتوي `props` و `copyWith`.
- [ ] كل **Model** هو `final class` يرث من Entity ويستخدم كلاسات الجداول المركزية.
- [ ] كل **Repository Interface** يستخدم `Future<Either<Failure, T>>`.
- [ ] كل **Repository Impl** يحتوي `try-catch` في جميع الدوال.
- [ ] كل **DataSource** يرمي `Exceptions` (وليس `Failures`).
- [ ] كل **Use Case** مسؤول عن مهمة واحدة فقط.
- [ ] الـ **Bloc** يحقن Use Cases حصراً (وليس Repositories).
- [ ] الـ **State** يحتوي `enum` للحالة ودوال `addItem`/`updateItem`/`removeItem`/`toError`.
- [ ] **لا يوجد** تعديل مباشر للقوائم داخل الـ Bloc.
- [ ] **لا يوجد** إعادة تحميل كاملة بعد CRUD (التحديث محلي فقط).
- [ ] **لا يوجد** نصوص ثابتة في الـ Bloc.
- [ ] ملف الحقن مُسجل في `injection_container.dart`.
- [ ] الصفحة الأصلية محذوفة أو مؤرشفة.

---

## ⚠️ محظورات عامة (Strict Prohibitions)

* **يمنع**: تجاوز الطبقات. كل طبقة لا تعرف إلا الطبقة التي تليها مباشرة.
* **يمنع**: وضع كل المنطق في Use Case واحد. كل Use Case لمهمة واحدة.
* **يمنع**: استخدام `setState` في الصفحة الجديدة (إلا لـ `AnimationController` أو `TextEditingController`).
* **يمنع**: استدعاء دوال أو حساب قيم من داخل الـ UI.
* **يمنع**: نسيان `try-catch` في Repository Impl.
* **يمنع**: استخدام نصوص مباشرة (`'id'`, `'name'`) في `fromMap`/`toMap`. الالتزام بكلاسات الجداول إلزامي.

---

> [!TIP]
> **الانتقال التدريجي**: عند تطبيق ذلك على مشروع قائم، حوّل صفحة صفحة، واختبر كل صفحة بعد التحويل مباشرة. لا تحاول تحويل كل الصفحات دفعة واحدة.
