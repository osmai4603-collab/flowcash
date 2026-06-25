# Walkthrough - Account Associations Feature

I have implemented the "Account Associations" (ارتباط الحسابات) feature within the System module. This feature allows users to manage entities associated with accounts, with conditional field visibility based on the account type.

## Changes Made

### BLoC Implementation
- Created `AccountAssociationsBloc` to manage the list of associations, including loading, searching, and CRUD operations.
- Created `AccountAssociationFormBloc` to manage the state of the association form, handling validation and conditional logic.

### UI Implementation
- Created `AccountAssociationsPage` which displays a table of associations. It includes an "Account Type" column and supports searching and filtering.
- Created `AccountAssociationFormPage` which provides a dialog for adding or editing associations.

### Conditional Logic
- In the `AccountAssociationFormPage`, fields for "Phone", "Address", and "Email" are only displayed if the selected account type is a "Person" type (Supplier, Customer, or Employee). This is implemented using `PersonType.isPerson`.

### Integration
- Added a new tab "ارتباط الحسابات" to the `SystemPage`.
- Registered the new BLoCs in the `system_injection.dart`.

## Verification Results

### Automated Checks
- Ran static analysis on all new and modified files; no errors or warnings were found.

### Manual Verification Steps (Recommended)
1.  Open the app and navigate to **System Settings**.
2.  Click on the new **Account Associations** tab.
3.  Verify that the table loads and shows the "Account Type" column.
4.  Click **Add New Association**:
    - Select "Customer" or "Supplier": Verify that Phone, Address, and Email fields appear.
    - Select "Bank" or "Revenue": Verify that Phone, Address, and Email fields are hidden.
5.  Save a new association and verify it appears in the list.
6.  Edit an existing association and verify changes are saved.
7.  Delete an association and verify it is removed from the list.
