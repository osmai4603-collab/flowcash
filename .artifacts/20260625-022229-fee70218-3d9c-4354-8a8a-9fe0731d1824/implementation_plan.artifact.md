# Implementation Plan - Account Associations Tab

Create a new "Account Associations" (ارتباط الحسابات) tab in the System feature. This feature allows managing all types of entities (Persons/Associations) that link to accounts (Receivable/Payable).

## User Review Required

- **Conditional Fields**: Phone number, address, and email will be hidden in the form if the Account Type is NOT one of (Supplier, Customer, Employee). This is based on `PersonType.isPerson`.
- **Existing Entity**: Using the existing `PersonEntity` and `PersonRepository` as they already support different types and account links.

## Proposed Changes

### [System Feature]

#### [system_injection.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/system_injection.dart)
- Register `AccountAssociationsBloc` and `AccountAssociationFormBloc` in the service locator.

#### [system_page.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/presentation/pages/system_page.dart)
- Add a new `PaneItem` for "Account Associations" (ارتباط الحسابات).

#### [NEW] [account_associations_bloc.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/presentation/bloc/account_associations/account_associations_bloc.dart)
- Handle loading, searching, adding, updating, and deleting associations.

#### [NEW] [account_associations_event.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/presentation/bloc/account_associations/account_associations_event.dart)
- Define events for `AccountAssociationsBloc`.

#### [NEW] [account_associations_state.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/presentation/bloc/account_associations/account_associations_state.dart)
- Define states for `AccountAssociationsBloc`.

#### [NEW] [account_association_form_bloc.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/presentation/bloc/account_association_form/account_association_form_bloc.dart)
- Handle state transitions for the association form.

#### [NEW] [account_association_form_event.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/presentation/bloc/account_association_form/account_association_form_event.dart)
- Define events for `AccountAssociationFormBloc`.

#### [NEW] [account_association_form_state.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/presentation/bloc/account_association_form/account_association_form_state.dart)
- Define states for `AccountAssociationFormBloc`, including a `toEntity()` method.

#### [NEW] [account_associations_page.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/presentation/pages/account_associations/account_associations_page.dart)
- UI for the list of associations with "Account Type" column.

#### [NEW] [account_association_form_page.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/system/presentation/pages/account_associations/account_association_form_page.dart)
- UI for the add/edit dialog with conditional fields.

## Verification Plan

### Automated Tests
- I will run the existing tests (if any) to ensure no regressions.
- I'll manually verify the UI and persistence.

### Manual Verification
- Navigate to "Settings" -> "Account Associations".
- Verify the list loads correctly.
- Add a new association with type "Customer" and verify phone/address/email fields are visible.
- Add a new association with type "Bank" and verify phone/address/email fields are hidden.
- Search for an association.
- Edit an existing association.
- Delete an association.
