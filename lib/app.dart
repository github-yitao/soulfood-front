import 'package:flutter/material.dart';
import 'package:soulfood_front/pages/root_page.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class SoulFoodApp extends StatelessWidget {
  const SoulFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DecideMeal',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD966)),
        fontFamily: 'PingFang SC',
      ),
      initialRoute: AppRoutes.root,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case AppRoutes.root:
            return MaterialPageRoute<void>(
              builder: (_) => const RootPage(),
              settings: settings,
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const RootPage(),
              settings: settings,
            );
        }
      },
    );
  }
}