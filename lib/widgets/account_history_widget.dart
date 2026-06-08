// import 'package:flowcash/core/entities/bill_entity.dart';
//
// import 'package:flowcash/database/models/inventory_transaction.dart';
// import 'package:flowcash/database/models/asset_buy.dart';
// import 'package:flowcash/database/models/bill.dart';
// import 'package:flowcash/database/models/financial_bond.dart';
// import 'package:flowcash/database/models/financial_transaction.dart';
// import 'package:flowcash/database/models/capital_transaction.dart';
// import 'package:flowcash/pages/model_widget/asset_transaction_widget.dart';
// import 'package:flowcash/pages/model_widget/bill_widget.dart';
// import 'package:flowcash/pages/model_widget/financial_bond_widget.dart';
// import 'package:flowcash/pages/model_widget/financial_transaction_widget.dart';
// import 'package:flowcash/pages/model_widget/voucher_bill_widget.dart';
// import 'package:flowcash/pages/model_widget/capital_transaction_widget.dart';
// import 'package:flowcash/widgets/my_text_widget.dart';
// import 'package:flutter/material.dart';
//
// class AccountHistoryWidget extends StatelessWidget {
//   final AccountingModel accountHistory;
//   final Future<void> Function(AccountingModel? history) onChangedData;
//   const AccountHistoryWidget({
//     super.key,
//     required this.accountHistory,
//     required this.onChangedData,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final history = accountHistory;
//     if (history is BillEntity) {
//       return BillWidget(bill: history);
//     }
//     if (history is FinancialBond) {
//       return FinancialBondWidget(
//         history: history,
//         onChangedData: onChangedData,
//       );
//     }
//     if (history is CapitalTransaction) {
//       return CapitalTransactionWidget(
//         history: history,
//         onChangedData: onChangedData,
//       );
//     }
//
//     if (history is FinancialTransaction) {
//       return FinancialTransactionWidget(
//         history: history,
//         onChangedData: onChangedData,
//       );
//     }
//
//     if (history is AssetTransaction) {
//       return AssetTransactionWidget(
//         history: history,
//         onChangedData: onChangedData,
//       );
//     }
//
//     if (history is InventoryTransaction) {
//       return VoucherWidget(voucher: history as InventoryTransaction);
//     }
//
//     return const Align(
//       alignment: Alignment.center,
//       child: SizedBox(
//         width: 500,
//         height: 63,
//         child: Card(
//           child: TextWidget(
//             text: 'لا يوجد اي وجهة لهذ السجل',
//             padding: EdgeInsets.all(10),
//           ),
//         ),
//       ),
//     );
//   }
// }
