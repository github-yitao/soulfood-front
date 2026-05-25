import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/agent/ai_quick_page.dart';
import 'package:soulfood_front/features/nearby/nearby_page.dart';
import 'package:soulfood_front/features/room/pages/create_room_page.dart';
import 'package:soulfood_front/features/room/pages/friends_page.dart';
import 'package:soulfood_front/features/room/pages/join_room_page.dart';
import 'package:soulfood_front/features/room/pages/recipe_result_page.dart';
import 'package:soulfood_front/features/room/pages/vote_page.dart';
import 'package:soulfood_front/features/room/room_models.dart';
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
      home: AppBootstrap(child: const RootPage()),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<void>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null || name == AppRoutes.root || name == '/') {
      return null;
    }
    switch (name) {
      case AppRoutes.friends:
        return MaterialPageRoute<void>(
          builder: (_) => const FriendsPage(),
          settings: settings,
        );
      case AppRoutes.createRoom:
        return MaterialPageRoute<void>(
          builder: (_) => const CreateRoomPage(),
          settings: settings,
        );
      case AppRoutes.joinRoom:
        return MaterialPageRoute<void>(
          builder: (_) => const JoinRoomPage(),
          settings: settings,
        );
      case AppRoutes.vote:
        final code = settings.arguments as String? ?? '';
        return MaterialPageRoute<void>(
          builder: (_) => VotePage(roomCode: code),
          settings: settings,
        );
      case AppRoutes.recipeResult:
        final args = settings.arguments;
        if (args is RoomResult) {
          return MaterialPageRoute<void>(
            builder: (_) => RecipeResultPage(voteResult: args),
            settings: settings,
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Center(child: Text('暂无投票结果'))),
          settings: settings,
        );
      case AppRoutes.aiQuick:
        return MaterialPageRoute<void>(
          builder: (_) => const AiQuickPage(),
          settings: settings,
        );
      case AppRoutes.nearby:
        return MaterialPageRoute<void>(
          builder: (_) => const NearbyPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const RootPage(),
          settings: settings,
        );
    }
  }
}
