import 'package:flowcash/core/enums/histories_group_enum.dart';

sealed class EntryType extends HistoriesGroup {
  const EntryType({
    required super.singleName,
    required super.totalName,
    required super.counterTypeName,
    required super.priority,
  });

  static const openingEntries = OpeningEntryType._();
  static const closingEntries = ClosingEntryType._();

  static const List<EntryType> values = [
    openingEntries,
    closingEntries,
  ];

  static EntryType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown EntryType: $name'),
    );
  }
}

final class OpeningEntryType extends EntryType {
  const OpeningEntryType._()
      : super(
          singleName: 'قيد افتتاحي',
          totalName: 'قيد افتتاحي',
          counterTypeName: 'قيد افتتاحي',
          priority: 13,
        );

  @override
  String get name => 'opening_entries';

  @override
  int get index => 12;

  @override
  String displayName() => 'قيد افتتاحي';
}

final class ClosingEntryType extends EntryType {
  const ClosingEntryType._()
      : super(
          singleName: 'قيد ختامي',
          totalName: 'قيد ختامي',
          counterTypeName: 'قيد ختامي',
          priority: 14,
        );

  @override
  String get name => 'closing_entries';

  @override
  int get index => 13;

  @override
  String displayName() => 'قيد ختامي';
}
