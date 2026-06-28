import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول الأشخاص.
class PersonsTable extends TableInfo {
  static final PersonsTable _instance = PersonsTable.internal();

  factory PersonsTable() => _instance;

  PersonsTable.internal();

  @override
  final String tableName = 'persons';

  final String id = 'person_id';
  final String personName = 'person_name';
  final String phoneNumber = 'phone_number';
  final String address = 'address';
  final String email = 'email';
  final String personType = 'person_type';
  final String receivableAccountId = 'receivable_account_id';
  final String payableAccountId = 'payable_account_id';
  final String createdAt = 'created_at';

  @override
  List<String> get columns => [id,
    personName,
    phoneNumber,
    address,
    email,
    personType,
    receivableAccountId,
    payableAccountId,
    createdAt,];
}
