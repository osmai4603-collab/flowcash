import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/styles.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_state.dart';
import 'package:flowcash/user_session.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class TableOfAccountGroup extends StatelessWidget {
  final MainAccountGroup accountType;
  final List<MainAccountEntity> mainAccounts;
  final int? selectedMainAccountId;
  final ValueChanged<MainAccountEntity> onMainAccountTap;
  final ValueChanged<MainAccountGroup> onAddMainAccount;

  const TableOfAccountGroup({
    super.key,
    required this.accountType,
    required this.mainAccounts,
    required this.onMainAccountTap,
    required this.onAddMainAccount,
    this.selectedMainAccountId,
  });

  int _getLengthOfAccountType() {
    final lengthOfCurrent = mainAccounts
        .where((account) => account.mainAccountType.accountType == accountType)
        .length;
    switch (accountType) {
      case MainAccountGroup.assets:
        final length = mainAccounts
            .where(
              (account) =>
                  account.mainAccountType.accountType ==
                  MainAccountGroup.liabilities,
            )
            .length;
        return lengthOfCurrent >= length ? lengthOfCurrent : length;
      case MainAccountGroup.liabilities:
        final length = mainAccounts
            .where(
              (account) =>
                  account.mainAccountType.accountType ==
                  MainAccountGroup.assets,
            )
            .length;
        return lengthOfCurrent >= length ? lengthOfCurrent : length;
      case MainAccountGroup.expenses:
        final length = mainAccounts
            .where(
              (account) =>
                  account.mainAccountType.accountType ==
                  MainAccountGroup.revenues,
            )
            .length;
        return lengthOfCurrent >= length ? lengthOfCurrent : length;
      case MainAccountGroup.revenues:
        final length = mainAccounts
            .where(
              (account) =>
                  account.mainAccountType.accountType ==
                  MainAccountGroup.expenses,
            )
            .length;
        return lengthOfCurrent >= length ? lengthOfCurrent : length;
      default:
        return lengthOfCurrent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final length = _getLengthOfAccountType();
    final accounts = mainAccounts
        .where((account) => account.mainAccountType.accountType == accountType)
        .toList();
    final colors = AppStyle.of(context);
    accounts.sort((a, b) => a.accountNumber.compareTo(b.accountNumber));
    return fluent.Table(
      border: fluent.TableBorder.all(
        color: colors.onSurface.withValues(alpha: 0.30),
        width: 0.5,
      ),
      children: [
        fluent.TableRow(
          children: [
            Container(
              height: 35.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5,
              ),
              color: colors.primary,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: fluent.Text(
                      accountType.displayName(),
                      textAlign: TextAlign.center,
                      style: colors.subTitle.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  fluent.Tooltip(
                    message: 'إضافة حساب رئيسي',
                    child: fluent.IconButton(
                      icon: fluent.Icon(
                        Icons.add,
                        size: 18,
                        color: colors.onPrimary,
                      ),

                      onPressed: () => onAddMainAccount(accountType),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ...List.generate(length, (index) {
          if (index >= accounts.length) {
            return TableRow(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: TextWidget(text: '', size: Size.fromHeight(30)),
                ),
              ],
            );
          }
          final mainAccount = accounts[index];
          final isSelected = selectedMainAccountId == mainAccount.id;
          return TableRow(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 30,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: 0.30)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: fluent.Text(mainAccount.accountName)),
                      fluent.Text(
                        AppMoneyFormatter.formatDouble(mainAccount.balance),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
                onTap: () => onMainAccountTap(mainAccount),
                onLongPress: () async {
                  final sure = await makeSure(
                    context: context,
                    title: mainAccount.accountName,
                    content: 'هل تريد حذف هذا الحساب الرئيسي',
                  );
                  if (sure && context.mounted) {
                    context.read<ChartOfAccountsBloc>().add(
                      DeleteMainAccount(mainAccount.id),
                    );
                  }
                  await successToast(
                    context: context,
                    toast: 'تم حذف الحساب الرئيسي بنجاح',
                  );
                },
              ),
            ],
          );
        }),
        TableRow(
          children: [
            Container(
              height: 30,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 3.0,
              ),
              child: fluent.Text(
                AppMoneyFormatter.formatDouble(
                  accounts.fold(0.0, (double pre, next) => pre + next.balance),
                ),
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MainGroupsWidget extends StatefulWidget {
  final ValueChanged<MainAccountEntity> onMainAccountSelected;
  final ValueChanged<MainAccountGroup> onAddMainAccount;
  final MainAccountEntity? selectedMainAccount;

  const MainGroupsWidget({
    super.key,
    required this.onMainAccountSelected,
    required this.onAddMainAccount,
    this.selectedMainAccount,
  });

  @override
  State<MainGroupsWidget> createState() => _MainGroupsWidgetState();
}

class _MainGroupsWidgetState extends State<MainGroupsWidget> {
  @override
  void initState() {
    super.initState();
    context.read<ChartOfAccountsBloc>().add(const LoadChartOfAccounts());
  }

  double _balanceOfAccountGroup(
    MainAccountGroup accountGroup,
    List<MainAccountEntity> mainAccounts,
  ) {
    return mainAccounts
        .where((account) => account.mainAccountType.accountType == accountGroup)
        .fold(0.0, (double pre, next) => pre + next.balance);
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<UserSession>().currentPeriod == null) {
      return const TextWidget(
        text: 'لا يوجد اي فترة محددة',
        size: Size(400, 300),
        alignment: Alignment.center,
      );
    }
    return BlocBuilder<ChartOfAccountsBloc, ChartOfAccountsState>(
      builder: (context, state) {
        if (state.status == ChartOfAccountsStatus.loading ||
            state.status == ChartOfAccountsStatus.initial) {
          return const SizedBox(
            height: 200,
            width: 400,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == ChartOfAccountsStatus.failure) {
          return TextWidget(
            text: state.errorMessage ?? 'حدث خطأ ما',
            size: const Size(400, 300),
            alignment: Alignment.center,
          );
        }
        final mainAccounts = state.mainAccounts;
        return Container(
          padding: const EdgeInsets.all(1),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TableOfAccountGroup(
                        accountType: MainAccountGroup.assets,
                        mainAccounts: mainAccounts,
                        selectedMainAccountId: widget.selectedMainAccount?.id,
                        onMainAccountTap: widget.onMainAccountSelected,
                        onAddMainAccount: widget.onAddMainAccount,
                      ),
                    ),
                    Expanded(
                      child: TableOfAccountGroup(
                        accountType: MainAccountGroup.liabilities,
                        mainAccounts: mainAccounts,
                        selectedMainAccountId: widget.selectedMainAccount?.id,
                        onMainAccountTap: widget.onMainAccountSelected,
                        onAddMainAccount: widget.onAddMainAccount,
                      ),
                    ),
                  ],
                ),
                TextWidget(
                  text: AppMoneyFormatter.formatDouble(
                    _balanceOfAccountGroup(
                          MainAccountGroup.assets,
                          mainAccounts,
                        ) -
                        _balanceOfAccountGroup(
                          MainAccountGroup.liabilities,
                          mainAccounts,
                        ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TableOfAccountGroup(
                        accountType: MainAccountGroup.expenses,
                        mainAccounts: mainAccounts,
                        selectedMainAccountId: widget.selectedMainAccount?.id,
                        onMainAccountTap: widget.onMainAccountSelected,
                        onAddMainAccount: widget.onAddMainAccount,
                      ),
                    ),
                    Expanded(
                      child: TableOfAccountGroup(
                        accountType: MainAccountGroup.revenues,
                        mainAccounts: mainAccounts,
                        selectedMainAccountId: widget.selectedMainAccount?.id,
                        onMainAccountTap: widget.onMainAccountSelected,
                        onAddMainAccount: widget.onAddMainAccount,
                      ),
                    ),
                  ],
                ),
                TextWidget(
                  text: AppMoneyFormatter.formatDouble(
                    _balanceOfAccountGroup(
                          MainAccountGroup.revenues,
                          mainAccounts,
                        ) -
                        _balanceOfAccountGroup(
                          MainAccountGroup.expenses,
                          mainAccounts,
                        ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Container()),
                    Expanded(
                      child: TableOfAccountGroup(
                        accountType: MainAccountGroup.propertyRights,
                        mainAccounts: mainAccounts,
                        selectedMainAccountId: widget.selectedMainAccount?.id,
                        onMainAccountTap: widget.onMainAccountSelected,
                        onAddMainAccount: widget.onAddMainAccount,
                      ),
                    ),
                  ],
                ),
                TextWidget(
                  text: AppMoneyFormatter.formatDouble(
                    _balanceOfAccountGroup(
                      MainAccountGroup.propertyRights,
                      mainAccounts,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 30,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        child: fluent.Text(
                          AppMoneyFormatter.formatDouble(
                            mainAccounts
                                .where(
                                  (account) => account
                                      .mainAccountType
                                      .accountType
                                      .accountStatus
                                      .isDebtor,
                                )
                                .fold(
                                  0.0,
                                  (double pre, next) => pre + next.balance,
                                ),
                          ),
                          textDirection: TextDirection.ltr,
                          style: Styles.titleMedium,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 30,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        child: fluent.Text(
                          AppMoneyFormatter.formatDouble(
                            mainAccounts
                                .where(
                                  (account) => account
                                      .mainAccountType
                                      .accountType
                                      .accountStatus
                                      .isCreditor,
                                )
                                .fold(
                                  0.0,
                                  (double pre, next) => pre + next.balance,
                                ),
                          ),
                          textDirection: TextDirection.ltr,
                          style: Styles.titleMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
