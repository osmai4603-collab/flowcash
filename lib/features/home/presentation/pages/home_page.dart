import 'package:flutter/material.dart' hide Colors, Text;
import 'package:go_router/go_router.dart';
import '../bloc/navigation_state.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentIcons, NavigationPane, NavigationView, PaneDisplayMode, PaneItem, Text;

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: navigationShell.currentIndex,
        onChanged: (index) => navigationShell.goBranch(index),
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.dashboard_add),
            title: Text(HomeSection.dashboard.displayName()),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: Text(HomeSection.system.displayName()),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.storage_optical),
            title: Text(HomeSection.databaseAdmin.displayName()),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people),
            title: Text(HomeSection.accounts.displayName()),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.shopping_cart),
            title: Text(HomeSection.inventory.displayName()),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.category_classification),
            title: Text(HomeSection.categories.displayName()),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.payment_card),
            title: Text(HomeSection.transactions.displayName()),
            body: navigationShell,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: Text(HomeSection.settings.displayName()),
            body: navigationShell,
          ),
        ],
      ),
    );
  }
}
