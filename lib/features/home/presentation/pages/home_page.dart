import 'package:flutter/material.dart' hide Colors, Text;
import 'package:go_router/go_router.dart';
import '../bloc/navigation_state.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return fluent.NavigationView(

      pane: fluent.NavigationPane(
        size: const fluent.NavigationPaneSize(
          openWidth: 200.0,    // تغيير العرض عند الفتح إلى 260 بكسل
          compactWidth: 60.0,  // تغيير العرض المدمج إلى 60 بكسل
        ),
        selected: navigationShell.currentIndex,
        onChanged: (index) => navigationShell.goBranch(index),
        displayMode: fluent.PaneDisplayMode.auto,
        items: [
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.dashboard_add),
            title: fluent.Text(HomeSection.dashboard.displayName()),
            body: navigationShell,
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.settings),
            title: fluent.Text(HomeSection.system.displayName()),
            body: navigationShell,
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.storage_optical),
            title: fluent.Text(HomeSection.databaseAdmin.displayName()),
            body: navigationShell,
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.people),
            title: fluent.Text(HomeSection.accounts.displayName()),
            body: navigationShell,
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.shopping_cart),
            title: fluent.Text(HomeSection.inventory.displayName()),
            body: navigationShell,
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.category_classification),
            title: fluent.Text(HomeSection.categories.displayName()),
            body: navigationShell,
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.payment_card),
            title: fluent.Text(HomeSection.transactions.displayName()),
            body: navigationShell,
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.settings),
            title: fluent.Text(HomeSection.settings.displayName()),
            body: navigationShell,
          ),
        ],
      ),
    );
  }
}
