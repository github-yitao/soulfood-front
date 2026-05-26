import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/classic_brand_mark.dart';
import 'package:soulfood_front/core/theme/classic_brand_palette.dart';
import 'package:soulfood_front/core/theme/classic_theme_copy.dart';
import 'package:soulfood_front/core/theme/ghoul_theme_copy.dart';
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
    final isGhoul = isGhoulTheme;

    return Scaffold(
      backgroundColor: isGhoul ? colors.heroGradientEnd : ClassicBrandPalette.scaffoldLight,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGhoul)
              const GhoulEyeMark(size: 96)
            else
              const ClassicBrandMark(size: 56, filled: true),
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
              isGhoul
                  ? '在饥饿与纠结之间，选出今晚的归宿'
                  : classicThemedText('帮你更快决定吃什么', warm: '帮你决定吃什么'),
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
