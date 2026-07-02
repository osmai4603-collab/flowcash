import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/user_session.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart' as material;

class HomeNavigationView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeNavigationView({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      // titleBar: const TitleBar(
      //   title: Text('نظام التدفق المالي'),
      //   isBackButtonVisible: false,
      // ),
      contentShape: RoundedRectangleBorder(borderRadius: Radiuses.none),
      pane: NavigationPane(
        size: const NavigationPaneSize(
          openWidth: 200.0,    // تغيير العرض عند الفتح إلى 260 بكسل
          compactWidth: 45.0,  // تغيير العرض المدمج إلى 60 بكسل
        ),
        // indicator: material.VerticalDivider(width: 0.0, color: style.primary),
        selected: navigationShell.currentIndex,
        onChanged: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.view_dashboard),
            title: const Text('لوحة المعلومات'),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.system),
            title: const Text('النظام'),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people),
            title: const Text('إدارة الحسابات'),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.shop),
            title: const Text('إدارة المخزون'),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.check_list),
            title: const Text('إدارة الفئات'),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.money),
            title: const Text('المعاملات المالية'),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.shop),
            title: const Text('المبيعات'),
            body: navigationShell,
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('الإعدادات'),
            body: navigationShell,
          ),
          PaneItemAction(
            icon: const Icon(FluentIcons.sign_out),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => ContentDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                  actions: [
                    Button(
                      child: const Text('إلغاء'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FilledButton(
                      child: const Text('تسجيل خروج'),
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<UserSession>().logout();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
