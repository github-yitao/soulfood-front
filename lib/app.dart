import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/settings/appearance_store.dart';
import 'package:soulfood_front/core/theme/app_theme_factory.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/core/auth/auth_session_guard.dart';
import 'package:soulfood_front/features/auth/forgot_password_page.dart';
import 'package:soulfood_front/features/auth/login_page.dart';
import 'package:soulfood_front/features/auth/splash_page.dart';
import 'package:soulfood_front/features/favorite/favorites_page.dart';
import 'package:soulfood_front/features/growth/about_page.dart';
import 'package:soulfood_front/features/growth/invite_page.dart';
import 'package:soulfood_front/features/nearby/nearby_page.dart';
import 'package:soulfood_front/features/nearby/restaurant_map_page.dart';
import 'package:soulfood_front/features/nearby/wanted_restaurants_page.dart';
import 'package:soulfood_front/features/nearby/random_eat_page.dart';
import 'package:soulfood_front/features/order/orders_page.dart';
import 'package:soulfood_front/features/preference/preference_page.dart';
import 'package:soulfood_front/features/growth/legal_document_page.dart';
import 'package:soulfood_front/features/notification/notifications_page.dart';
import 'package:soulfood_front/features/profile/bind_phone_page.dart';
import 'package:soulfood_front/features/profile/appearance_page.dart';
import 'package:soulfood_front/features/profile/settings_page.dart';
import 'package:soulfood_front/features/agent/ai_conversations_page.dart';
import 'package:soulfood_front/features/agent/ai_memory_page.dart';
import 'package:soulfood_front/features/agent/ai_chat_page.dart';
import 'package:soulfood_front/features/agent/ai_quick_page.dart';
import 'package:soulfood_front/features/recipe/cook_mode_page.dart';
import 'package:soulfood_front/features/recipe/recipe_library_page.dart';
import 'package:soulfood_front/features/room/pages/create_room_page.dart';
import 'package:soulfood_front/features/friend/my_friends_page.dart';
import 'package:soulfood_front/features/room/pages/friends_page.dart';
import 'package:soulfood_front/features/room/pages/join_room_page.dart';
import 'package:soulfood_front/features/room/pages/scan_join_room_page.dart';
import 'package:soulfood_front/features/room/pages/recipe_result_page.dart';
import 'package:soulfood_front/features/room/pages/vote_page.dart';
import 'package:soulfood_front/features/room/room_models.dart';
import 'package:soulfood_front/l10n/app_localizations.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class SoulFoodApp extends StatelessWidget {
  const SoulFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBootstrap(child: const _DecideMealApp());
  }
}

class _DecideMealApp extends StatefulWidget {
  const _DecideMealApp();

  @override
  State<_DecideMealApp> createState() => _DecideMealAppState();
}

class _DecideMealAppState extends State<_DecideMealApp> {
  @override
  void initState() {
    super.initState();
    AppServices.I.appearanceNotifier.addListener(_onAppearanceChanged);
  }

  @override
  void dispose() {
    AppServices.I.appearanceNotifier.removeListener(_onAppearanceChanged);
    super.dispose();
  }

  void _onAppearanceChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final settings = AppServices.I.appearanceNotifier.value;

    final classicLight = AppThemeFactory.classicLight();
    final classicDark = AppThemeFactory.classicDark();
    final ghoul = AppThemeFactory.ghoul();

    final isGhoul = settings.variant == AppThemeVariant.ghoul;
    final themeMode = isGhoul
        ? ThemeMode.dark
        : switch (settings.mode) {
            AppThemeMode.light => ThemeMode.light,
            AppThemeMode.dark => ThemeMode.dark,
            AppThemeMode.system => ThemeMode.system,
          };

    return MaterialApp(
      navigatorKey: AuthSessionGuard.navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'DecideMeal',
      locale: Locale(settings.locale.languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: themeMode,
      theme: isGhoul ? ghoul : classicLight,
      darkTheme: isGhoul ? ghoul : classicDark,
      home: const SplashPage(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<void>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null || name == AppRoutes.root || name == '/') {
      return null;
    }
    switch (name) {
      case AppRoutes.login:
        return MaterialPageRoute<void>(builder: (_) => const LoginPage(), settings: settings);
      case AppRoutes.friends:
        return MaterialPageRoute<void>(builder: (_) => const FriendsPage(), settings: settings);
      case AppRoutes.myFriends:
        return MaterialPageRoute<void>(builder: (_) => const MyFriendsPage(), settings: settings);
      case AppRoutes.createRoom:
        return MaterialPageRoute<void>(builder: (_) => const CreateRoomPage(), settings: settings);
      case AppRoutes.joinRoom:
        return MaterialPageRoute<void>(builder: (_) => const JoinRoomPage(), settings: settings);
      case AppRoutes.scanJoinRoom:
        return MaterialPageRoute<void>(builder: (_) => const ScanJoinRoomPage(), settings: settings);
      case AppRoutes.vote:
        final code = settings.arguments as String? ?? '';
        return MaterialPageRoute<void>(builder: (_) => VotePage(roomCode: code), settings: settings);
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
        return MaterialPageRoute<void>(builder: (_) => const AiQuickPage(), settings: settings);
      case AppRoutes.aiChat:
        final args = settings.arguments;
        if (args == 'new') {
          return MaterialPageRoute<void>(
            builder: (_) => const AiChatPage(isNewChat: true),
            settings: settings,
          );
        }
        if (args is String && args.isNotEmpty) {
          return MaterialPageRoute<void>(
            builder: (_) => AiChatPage(conversationId: args),
            settings: settings,
          );
        }
        return MaterialPageRoute<void>(builder: (_) => const AiChatPage(), settings: settings);
      case AppRoutes.aiConversations:
        return MaterialPageRoute<void>(builder: (_) => const AiConversationsPage(), settings: settings);
      case AppRoutes.aiMemory:
        return MaterialPageRoute<void>(builder: (_) => const AiMemoryPage(), settings: settings);
      case AppRoutes.recipeLibrary:
        return MaterialPageRoute<void>(builder: (_) => const RecipeLibraryPage(), settings: settings);
      case AppRoutes.randomEat:
        return MaterialPageRoute<void>(builder: (_) => const RandomEatPage(), settings: settings);
      case AppRoutes.nearby:
        return MaterialPageRoute<void>(builder: (_) => const NearbyPage(), settings: settings);
      case AppRoutes.restaurantMap:
        return MaterialPageRoute<void>(builder: (_) => const RestaurantMapPage(), settings: settings);
      case AppRoutes.wantedRestaurants:
        return MaterialPageRoute<void>(builder: (_) => const WantedRestaurantsPage(), settings: settings);
      case AppRoutes.cookMode:
        return MaterialPageRoute<void>(builder: (_) => const CookModePage(), settings: settings);
      case AppRoutes.forgotPassword:
        return MaterialPageRoute<void>(builder: (_) => const ForgotPasswordPage(), settings: settings);
      case AppRoutes.bindPhone:
        return MaterialPageRoute<void>(builder: (_) => const BindPhonePage(), settings: settings);
      case AppRoutes.favorites:
        return MaterialPageRoute<void>(builder: (_) => const FavoritesPage(), settings: settings);
      case AppRoutes.preference:
        return MaterialPageRoute<void>(builder: (_) => const PreferencePage(), settings: settings);
      case AppRoutes.orders:
        return MaterialPageRoute<void>(builder: (_) => const OrdersPage(), settings: settings);
      case AppRoutes.settings:
        return MaterialPageRoute<void>(builder: (_) => const SettingsPage(), settings: settings);
      case AppRoutes.appearance:
        return MaterialPageRoute<void>(builder: (_) => const AppearancePage(), settings: settings);
      case AppRoutes.about:
        return MaterialPageRoute<void>(builder: (_) => const AboutPage(), settings: settings);
      case AppRoutes.invite:
        return MaterialPageRoute<void>(builder: (_) => const InvitePage(), settings: settings);
      case AppRoutes.legalTerms:
        return MaterialPageRoute<void>(
          builder: (_) => const LegalDocumentPage(type: LegalDocumentType.terms),
          settings: settings,
        );
      case AppRoutes.legalPrivacy:
        return MaterialPageRoute<void>(
          builder: (_) => const LegalDocumentPage(type: LegalDocumentType.privacy),
          settings: settings,
        );
      case AppRoutes.notifications:
        return MaterialPageRoute<void>(builder: (_) => const NotificationsPage(), settings: settings);
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
    }
  }
}
