/// ثوابت جدول الأشخاص.
class PersonsTable {
  const PersonsTable._();

  static const String tableName = 'persons';

  static const String id = 'person_id';
  static const String personName = 'person_name';
  static const String phoneNumber = 'phone_number';
  static const String address = 'address';
  static const String email = 'email';
  static const String personType = 'person_type';
  static const String receivableAccountId = 'receivable_account_id';
  static const String payableAccountId = 'payable_account_id';
  static const String createdAt = 'created_at';

  static const List<String> fields = [
    id,
    personName,
    phoneNumber,
    address,
    email,
    personType,
    receivableAccountId,
    payableAccountId,
    createdAt,
  ];
}
