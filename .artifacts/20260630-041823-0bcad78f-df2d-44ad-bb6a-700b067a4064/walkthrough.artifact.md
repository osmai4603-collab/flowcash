# Walkthrough - Property ID-based Unit Fetching

I have implemented a new feature to fetch units for a specific subcategory based on a provided list of property IDs, using a nested subquery for optimal database performance.

## Changes Made

### Data Layer
- **`UnitLocalDataSource`**: Added `getUnitsBySubcategoryAndPropertyIds` to the interface.
- **`UnitLocalDataSourceImpl`**: Implemented the method using the requested SQL structure:
  ```sql
  SELECT * FROM units
  WHERE unit_id IN (
    SELECT unit_id
    FROM subcategories_units
    WHERE subcategory_id = ?
    AND property_id IN (?, ?, ...)
  )
  ```
- **`UnitRepository` & `UnitRepositoryImpl`**: Added and implemented the new method in the repository layer.

### Domain Layer
- **`GetUnitsBySubcategoryAndPropertyIdsUseCase`**: Created a new UseCase to expose this functionality to the presentation layer.

### Presentation Layer (DI)
- **`categories_injection.dart`**: Registered the new UseCase in the `GetIt` service locator.
- **Bonus Fix**: Noticed and fixed a missing DI registration for `GetSubcategoryUnitsByTypeUseCase` which was previously added but not registered in the injection container.

## Technical Details
The new method dynamically handles a variable number of property IDs by generating the appropriate number of placeholders (`?`) for the SQL `IN` clause, ensuring safe and efficient execution.

## Verification Summary
- **Syntax Check**: Ran `analyze_file` on all modified files; no errors or warnings were found.
- **SQL Logic**: Manually verified the SQL query against the database schema to ensure it correctly joins units with subcategories via property IDs.
- **DI Container**: Verified that the new UseCase is correctly registered and available for injection.
