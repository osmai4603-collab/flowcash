# Implementation Plan - Integrating GetUnitsBySubcategoryIdsUseCase in CategoryFormBloc

Replace the complex property-based unit fetching logic in `CategoryFormBloc` with the newly created `GetUnitsBySubcategoryIdsUseCase` to fetch all units related to a selected subcategory.

## Proposed Changes

### Presentation Layer

#### [category_form_bloc.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/presentation/blocs/category_form/category_form_bloc.dart)
- Remove `GetSubcategoryUnitsByTypeUseCase` dependency.
- Add `GetUnitsBySubcategoryIdsUseCase` dependency.
- Update constructor and private fields.
- Refactor `_onChangeCategorySubcategory`:
    - Call `_getUnitsBySubcategoryIdsUseCase` with the selected subcategory's ID.
    - Update `_pricingsUnits` and `_inventoriesUnits` with the result.
    - Note: Since the new UseCase returns all units for the subcategory without filtering by type, both lists will initially contain all retrieved units.
- Refactor `_onInit`:
    - Use `_getUnitsBySubcategoryIdsUseCase` when a subcategory is present during initialization.

#### [category_form_page.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/categories/presentation/pages/categories/category_form_page.dart)
- Update `CategoryFormBloc` instantiation to inject `GetUnitsBySubcategoryIdsUseCase` instead of `GetSubcategoryUnitsByTypeUseCase`.

## Verification Plan

### Automated Tests
- Run `analyze_file` on modified files to ensure syntax correctness.

### Manual Verification
- Verify that when a subcategory is selected, the unit dropdowns are populated correctly with the units associated with that subcategory.
