import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/core/theme/ghoul_eye_mark.dart';
import 'package:soulfood_front/features/auth/login_page.dart';
import 'package:soulfood_front/features/room/room_deep_link.dart';
import 'package:soulfood_front/pages/root_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await RoomDeepLinkListener.captureInitialLink();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final loggedIn = AppServices.I.auth.isLoggedIn;
    if (!loggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      );
      return;
    }

    final joined = await RoomDeepLinkListener.tryConsumePendingJoin(context);
    if (!mounted || joined) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RootPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isGhoul = AppServices.I.appearance.variant == AppThemeVariant.ghoul;

    return Scaffold(
      backgroundColor: isGhoul ? colors.heroGradientEnd : null,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGhoul)
              const GhoulEyeMark(size: 96)
            else
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.heroGradientStart, colors.accent],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colors.splashGlow,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.ramen_dining, color: colors.onAccent, size: 44),
              ),
            const SizedBox(height: 16),
            Text(
              'DecideMeal',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: isGhoul ? 1.2 : 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isGhoul ? '在黑暗中，做出你的选择' : '帮你更快决定吃什么',
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
