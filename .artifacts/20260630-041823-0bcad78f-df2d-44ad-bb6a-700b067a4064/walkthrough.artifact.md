# Walkthrough - Refactoring Subcategory Unit Fetching

I have refactored the logic for fetching units when a subcategory is changed in the `CategoryFormBloc`. The previous implementation made multiple separate calls and performed manual filtering in the BLoC. The new implementation uses a single, optimized database query via a dedicated UseCase.

## Changes Made

### Domain Layer
- Created a new entity/DTO `SubcategoryUnits` to hold grouped pricing and inventory units.
- Added `getSubcategoryUnitsByType` to `UnitRepository`.
- Created `GetSubcategoryUnitsByTypeUseCase` in `unit_usecases.dart`.

### Data Layer
- Added `getSubcategoryUnitsByType` to `UnitLocalDataSource` and implemented it in `UnitLocalDataSourceImpl`.
- The implementation uses a single SQL query with `JOIN` and `GROUP BY` to fetch all relevant units and their properties (pricing/inventory) in one go.
- Updated `UnitRepositoryImpl` to support the new method.

### Presentation Layer
- Refactored `CategoryFormBloc`:
    - Removed `GetCategoryPropertiesByMainCategoryUseCase` and `GetUnitsUseCase` dependencies as they are no longer needed here.
    - Injected `GetSubcategoryUnitsByTypeUseCase`.
    - Simplified `_onChangeCategorySubcategory` to use the new UseCase, significantly reducing code complexity.
    - Updated `_onInit` to correctly populate the unit lists when a subcategory is pre-selected.
- Updated `CategoryFormPage` to provide the new UseCase to the BLoC.

## Technical Details

The core of the change is the optimized SQL query in `UnitLocalDataSourceImpl`:

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

This query ensures that we get each unit only once, while correctly identifying if it serves as a pricing unit, an inventory unit, or both for the given subcategory.

## Verification Summary
- Verified that all modified files are free of syntax errors using `analyze_file`.
- Removed unused imports in `CategoryFormBloc` resulting from the refactoring.
- Manually reviewed the SQL query and the mapping logic in the data source to ensure correctness.
