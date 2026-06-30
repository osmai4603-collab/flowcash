# Implementation Plan - Optimized Subcategory Unit Fetching

Refactor the subcategory unit selection logic to use a single database query and a dedicated UseCase.

## Proposed Changes

### Domain Layer
#### [subcategory_units.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/domain/entities/subcategory_units.dart) [NEW]
- Define a DTO class `SubcategoryUnits` to hold two lists: `pricingUnits` and `inventoryUnits`.

#### [unit_repository.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/domain/repositories/unit_repository.dart)
- Add `getSubcategoryUnitsByType(int subcategoryId)` method.

#### [unit_usecases.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/domain/usecases/unit_usecases.dart)
- Implement `GetSubcategoryUnitsByTypeUseCase`.

### Data Layer
#### [unit_data_source.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/data/datasources/unit_data_source.dart)
- Add `getSubcategoryUnitsByType(int subcategoryId)` returning a map of unit lists.

#### [unit_local_data_source_impl.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/data/datasources/unit_local_data_source_impl.dart)
- Implement the method using an optimized SQL query:
```sql
SELECT u.*,
       MAX(cp.is_pricing_unit) as is_pricing_unit,
       MAX(cp.is_inventory_unit) as is_inventory_unit
FROM units u
JOIN subcategories_units su ON u.unit_id = su.unit_id
JOIN categories_properties cp ON su.property_id = cp.property_id
WHERE su.subcategory_id = ?
GROUP BY u.unit_id
```

#### [unit_repository_impl.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/data/repositories/unit_repository_impl.dart)
- Map the data source result to the `SubcategoryUnits` entity.

### Presentation Layer
#### [category_form_bloc.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/presentation/blocs/category_form/category_form_bloc.dart)
- Replace `GetCategoryPropertiesByMainCategoryUseCase` and `GetUnitsUseCase` with the new `GetSubcategoryUnitsByTypeUseCase`.
- Simplify `_onChangeCategorySubcategory` and `_onInit` logic.

#### [category_form_page.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/presentation/pages/categories/category_form_page.dart)
- Update DI instantiation.

## Verification Plan
### Automated Tests
- Run `analyze_file` on all modified files to ensure no syntax errors or unused imports.
### Manual Verification
- Review SQL query for correctness and efficiency.
- Ensure all dependencies are correctly injected.
