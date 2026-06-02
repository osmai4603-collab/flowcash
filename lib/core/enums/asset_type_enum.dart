import 'package:flowcash/core/enums/histories_group_enum.dart';

sealed class AssetType extends HistoriesGroup {
  const AssetType({
    required super.singleName,
    required super.totalName,
    required super.counterTypeName,
    required super.priority,
  });

  static const assetsBuys = AssetsBuysType._();
  static const assetsSales = AssetsSalesType._();

  static const List<AssetType> values = [
    assetsBuys,
    assetsSales,
  ];

  static AssetType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown AssetType: $name'),
    );
  }
}

final class AssetsBuysType extends AssetType {
  const AssetsBuysType._()
      : super(
          singleName: 'شراء أصل',
          totalName: 'مشتريات اصول',
          counterTypeName: 'مشتريات اصول',
          priority: 11,
        );

  @override
  String get name => 'assets_buys';

  @override
  int get index => 10;

  @override
  String displayName() => 'شراء أصل';
}

final class AssetsSalesType extends AssetType {
  const AssetsSalesType._()
      : super(
          singleName: 'بيع أصل',
          totalName: 'مبيعات اصول',
          counterTypeName: 'مبيعات اصول',
          priority: 12,
        );

  @override
  String get name => 'assets_sales';

  @override
  int get index => 11;

  @override
  String displayName() => 'بيع أصل';
}
