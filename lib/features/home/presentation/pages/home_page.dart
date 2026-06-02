import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../bloc/navigation_state.dart';

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
      iconData: Icons.dashboard_customize_outlined,
    ),
    HomeSectionItem(
      section: HomeSection.periods,
      iconData: Icons.view_timeline_sharp,
    ),
    HomeSectionItem(
      section: HomeSection.currencies,
      iconData: Icons.currency_exchange_outlined,
    ),
    HomeSectionItem(
      section: HomeSection.databaseAdmin,
      iconData: Icons.storage_outlined,
    ),
    HomeSectionItem(
      section: HomeSection.accounts,
      iconData: Icons.people_outline,
    ),
    HomeSectionItem(
      section: HomeSection.inventory,
      iconData: Icons.local_grocery_store_outlined,
    ),
    HomeSectionItem(
      section: HomeSection.categories,
      iconData: Icons.category_outlined,
    ),
    HomeSectionItem(
      section: HomeSection.settings,
      iconData: Icons.settings_rounded,
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
    final currentIndex = navigationShell.currentIndex;
    final isSettingsSelected = currentIndex >= 7;
    return BottomNavigationBar(
      currentIndex: isSettingsSelected ? 0 : currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        navigationShell.goBranch(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_customize_outlined),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_timeline_sharp),
          label: 'الفترات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.currency_exchange_outlined),
          label: 'العملات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.storage_outlined),
          label: 'قاعدة البيانات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'الحسابات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_grocery_store_outlined),
          label: 'المخزون',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          label: 'الفئات',
        ),
      ],
    );
  }
}
