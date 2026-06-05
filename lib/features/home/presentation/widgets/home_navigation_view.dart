import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import '../bloc/navigation_state.dart';

class HomeNavigationView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeNavigationView({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      titleBar: const TitleBar(
        title: Text('نظام التدفق المالي'),
        isBackButtonVisible: false,
      ),
      pane: NavigationPane(
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
            icon: const Icon(FluentIcons.database),
            title: const Text('إدارة قاعدة البيانات'),
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
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('الإعدادات'),
            body: navigationShell,
          ),
        ],
      ),
    );
  }
}
