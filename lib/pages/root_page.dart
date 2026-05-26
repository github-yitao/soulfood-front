import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/ghoul_theme_copy.dart';
import 'package:soulfood_front/features/room/room_deep_link.dart';
import 'package:soulfood_front/l10n/app_localizations.dart';
import 'package:soulfood_front/pages/discover_page.dart';
import 'package:soulfood_front/pages/home_page.dart';
import 'package:soulfood_front/pages/profile_page.dart';
import 'package:soulfood_front/pages/records_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) RoomDeepLinkListener.listenWhileMounted(context);
    });
  }

  static const List<Widget> _tabs = <Widget>[
    HomePage(),
    DiscoverPage(),
    RecordsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() => _selectedIndex = index);
        },
        height: 84,
        backgroundColor: colors.navBackground,
        indicatorColor: colors.navIndicator,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: ghoulThemedText(l10n.tabHome, ghoul: '今夜'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_outlined),
            selectedIcon: const Icon(Icons.restaurant_rounded),
            label: ghoulThemedText(l10n.tabDiscover, ghoul: '猎食'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history_rounded),
            label: ghoulThemedText(l10n.tabRecords, ghoul: '喰迹'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: ghoulThemedText(l10n.tabMine, ghoul: '档案'),
          ),
        ],
      ),
    );
  }
}
