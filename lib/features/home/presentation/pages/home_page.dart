import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../bloc/navigation_state.dart';

import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
final class HomeSectionItem {
  final HomeSection section;
  final IconData iconData;

  String displayName() {
    return section.displayName();
  }

  const HomeSectionItem({required this.section, required this.iconData});
}

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 820;
    return Scaffold(
      drawer: isDesktop ? null : _HomeDrawer(navigationShell: navigationShell),
      body: Row(
        children: [
          if (isDesktop) SizedBox(width: 280, child: _HomeDrawer(navigationShell: navigationShell)),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _BottomNavigationBar(navigationShell: navigationShell),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _HomeDrawer({required this.navigationShell});

  List<HomeSectionItem> get sections => [
    HomeSectionItem(
      section: HomeSection.dashboard,
      iconData: FluentIcons.dashboard_add,
    ),
    HomeSectionItem(
      section: HomeSection.system,
      iconData: FluentIcons.settings,
    ),
    HomeSectionItem(
      section: HomeSection.databaseAdmin,
      iconData: FluentIcons.storage_optical,
    ),
    HomeSectionItem(
      section: HomeSection.accounts,
      iconData: FluentIcons.people,
    ),
    HomeSectionItem(
      section: HomeSection.inventory,
      iconData: FluentIcons.shopping_cart,
    ),
    HomeSectionItem(
      section: HomeSection.categories,
      iconData: FluentIcons.category_classification,
    ),
    HomeSectionItem(
      section: HomeSection.transactions,
      iconData: FluentIcons.payment_card,
    ),
    HomeSectionItem(
      section: HomeSection.settings,
      iconData: FluentIcons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: ColorScheme.of(context).primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Text(
                      'نظام التدفق المالي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'لوحة النظام الأساسية',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: sections
                    .map(
                      (item) => _HomeMenuTile(
                        icon: item.iconData,
                        section: item.section,
                        selected: navigationShell.currentIndex == item.section.index,
                        onTap: () {
                          navigationShell.goBranch(item.section.index);
                          if (Scaffold.of(context).isDrawerOpen) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeMenuTile extends StatelessWidget {
  final IconData icon;
  final HomeSection section;
  final bool selected;
  final VoidCallback onTap;

  const _HomeMenuTile({
    required this.icon,
    required this.section,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      leading: Icon(icon, color: ColorScheme.of(context).onSurface),
      title: Text(section.displayName()),
      onTap: onTap,
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _BottomNavigationBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        navigationShell.goBranch(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.dashboard_add),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.settings),
          label: 'النظام',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.storage_optical),
          label: 'قاعدة البيانات',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.people),
          label: 'الحسابات',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.shopping_cart),
          label: 'المخزون',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.category_classification),
          label: 'الفئات',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.payment_card),
          label: 'المعاملات',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.settings),
          label: 'الإعدادات',
        ),
      ],
    );
  }
}
