import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD36E), Color(0xFFFF9F5A)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40FF904B),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.ramen_dining, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'DecideMeal',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              '帮你更快决定吃什么',
              style: TextStyle(color: Color(0xFF8D919A)),
            ),
          ],
        ),
      ),
    );
  }
}
