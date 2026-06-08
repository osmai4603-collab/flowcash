import 'package:money_formatter/money_formatter.dart';

abstract class AppMoneyFormatter {
  static final MoneyFormatterSettings _settings = MoneyFormatterSettings(
    symbol: '',
    thousandSeparator: ',',
    decimalSeparator: '.',
    symbolAndNumberSeparator: '',
    fractionDigits: 2,
    compactFormatType: CompactFormatType.long,
  );

  /// تنسيق نص المبلغ المالي ليحتوي على فواصل الآلاف
  static String formatString(String money) {
    if (money.isEmpty) return money;
    final amount = RegExp(r'[0-9.]+').hasMatch(money)
        ? double.tryParse(money) ?? 0.0
        : 0.0;
    return formatDouble(amount);
  }

  /// تنسيق قيمة double المبلغ المالي
  static String formatDouble(double money) {
    if (money == double.infinity || money.isNaN) return '';
    return MoneyFormatter(
      amount: money,
      settings: _settings,
    ).output.nonSymbol.replaceFirst('.00', '');
  }
}
