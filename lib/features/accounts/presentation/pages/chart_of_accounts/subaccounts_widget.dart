import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme/styles.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_state.dart';
import 'package:flowcash/features/accounts/presentation/pages/account_statement/account_statement_page.dart';
import 'package:flowcash/features/accounts/presentation/pages/accounts_page.dart';
import 'package:flowcash/features/accounts/presentation/pages/chart_of_accounts/sub_account_form_dialog.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SubAccountsViewWidget extends StatefulWidget {
  final MainAccountEntity mainAccount;
  final ValueChanged<MainAccountEntity> onMainAccountChanged;

  const SubAccountsViewWidget({
    super.key,
    required this.mainAccount,
    required this.onMainAccountChanged,
  });

  @override
  State<SubAccountsViewWidget> createState() => _SubAccountsViewWidgetState();
}

class _SubAccountsViewWidgetState extends State<SubAccountsViewWidget> {
  final searchBarController = TextEditingController();

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  Widget buildIconResetAccountBalance(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final result = await makeSure(
          title:
              '${widget.mainAccount.accountName} ${widget.mainAccount.accountNumber}',
          content: 'هل انت متأكد من انك تريد اعادة هيكلة الحساب ؟',
          context: context,
        );
        if (!result) return;
        if (context.mounted) {
          // context.read<ChartOfAccountsBloc>().add(
          //   ResetMainAccountBalanceEvent(widget.mainAccount.id),
          // );
          // await successToast(
          //   toast: 'تم اعادة هيكلة الحساب بنجاح',
          //   context: context,
          // );
        }
      },
      tooltip: 'اعادة اجمالي رصيد الحساب',
      icon: const Icon(Icons.lock_reset_outlined, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: BlocBuilder<ChartOfAccountsBloc, ChartOfAccountsState>(
        builder: (context, state) {
          if (state.status == ChartOfAccountsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
    
          final accounts = _getFilteredAccounts(state.subAccounts);
          return _buildListView(context, accounts);
        },
      ),
    );
  }

  List<SubAccountEntity> _getFilteredAccounts(List<SubAccountEntity> accounts) {
    final selectedAccounts = accounts
        .where((account) => account.mainAccountId == widget.mainAccount.id)
        .toList();
    if (searchBarController.text.isEmpty) return selectedAccounts;
    final query = searchBarController.text.toLowerCase();
    return selectedAccounts
        .where(
          (account) =>
              account.accountName.toLowerCase().contains(query) ||
              account.accountNumber.toLowerCase().contains(query),
        )
        .toList();
  }

  Widget _buildListView(BuildContext context, List<SubAccountEntity> accounts) {
    final colors = AppStyle.of(context);
    return ValueListenableBuilder(
      valueListenable: searchBarController,
      builder: (_, value, child) {
        final filtered = _getFilteredAccounts(accounts);
        final incrementsSum = filtered.fold(
          0.0,
          (double pre, next) => pre + next.debitBalance,
        );
        final decrementsSum = filtered.fold(
          0.0,
          (double pre, next) => pre + next.creditBalance,
        );
        final totalBalance = incrementsSum - decrementsSum;


        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: fluent.Text(
                    'الحسابات الفرعية لـ ${widget.mainAccount.accountName}',
                    
                  ),
                ),
                fluent.FilledButton(

                  onPressed: () => _showAddSubAccountDialog(context),
                  child: const Text('إضافة حساب فرعي'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'لا يوجد حسابات ${widget.mainAccount.accountName}',
                        style: colors.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: colors.onSurface.withValues(alpha: 0.30)),
                      itemBuilder: (context, index) {
                        final subAccount = filtered[index];
                        return _buildPersonRow(context, subAccount);
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: ColorScheme.of(context).primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'له: ${AppMoneyFormatter.formatDouble(incrementsSum)}',
                    style: colors.title.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    'الرصيد: ${AppMoneyFormatter.formatDouble(totalBalance)}',
                    style: colors.title.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    'عليه: ${AppMoneyFormatter.formatDouble(decrementsSum)}',
                    style: colors.title.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonRow(BuildContext context, SubAccountEntity subAccount) {
    final imagePath = _getImagePathForType(subAccount.subAccountType.name);
    final currencyLabel = subAccount.currencyId;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        minVerticalPadding: 1,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        leading: SizedBox(width: 50, child: Image.asset(imagePath)),
        title: Text(subAccount.accountName),
        subtitle: Text(subAccount.accountNumber),
        trailing: Text(
          '$currencyLabel ${AppMoneyFormatter.formatDouble(subAccount.balance)}',
          textDirection: TextDirection.ltr,
        ),
        onTap: () => _onNavigateToHistories(context, subAccount),
        onLongPress: () => _onLongPressSubAccount(context, subAccount),
      ),
    );
  }

  String _getImagePathForType(String typeName) {
    switch (typeName) {
      case 'cashTreasury':
      case 'cashBank':
        return 'images/cash_balance.png';
      case 'clients':
        return 'images/client.png';
      case 'suppliers':
        return 'images/supplier.png';
      case 'revenues':
      case 'sales':
      case 'buysReturn':
      case 'moneyHead':
      case 'profitsAndLoss':
        return 'images/revenues.png';
      case 'expenses':
      case 'operationalExpenses':
      case 'buys':
      case 'salesReturn':
        return 'images/expenses.png';
      case 'inventory':
        return 'images/stores.png';
      case 'tangibleAssets':
      case 'inTangibleAssets':
        return 'images/asset.png';
      default:
        return 'images/client.png';
    }
  }

  void _onNavigateToHistories(
    BuildContext context,
    SubAccountEntity entity,
  ) async {
    try {
      Provider.of<AccountsTabNotifier>(context, listen: false)
          .navigateToAccountStatement(entity.id);
    } catch (_) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AccountStatementPage(),
          ),
        );
      }
    }
  }

  Future<void> _showAddSubAccountDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SubAccountFormDialog(
        mainAccountId: widget.mainAccount.id,
      ),
    );
    if (result == true && context.mounted) {
      context.read<ChartOfAccountsBloc>().add(const LoadChartOfAccounts());
    }
  }

  void _onLongPressSubAccount(
    BuildContext context,
    SubAccountEntity subAccount,
  ) async {
    final sure = await makeSure(
      context: context,
      title: subAccount.accountName,
      content: 'هل تريد حذف هذا الحساب الفرعي',
    );
    if (!sure) return;

    if (context.mounted) {
      context.read<ChartOfAccountsBloc>().add(DeleteSubAccount(subAccount.id));
      await successToast(
        context: context,
        toast: 'تم حذف الحساب: ${subAccount.accountName} بنجاح',
      );
    }
  }
}
