import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

/// واجهة مستودع خصائص التصنيف
abstract interface class CategoryAttributeRepository
    implements RepositoryDB<CategoryAttributeEntity> {
  /// جلب خصائص حسب معرفات التصنيف.
  Future<Either<Failure, List<CategoryAttributeEntity>>> whereCategoryId(
    Iterable<int> ids,
  );

  /// جلب خصائص حسب معرفات معلومات الكاتالوج.
  Future<Either<Failure, List<CategoryAttributeEntity>>> whereSubcategoryUnitId(
    Iterable<int> ids,
  );
}
