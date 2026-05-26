import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/auth/login_page.dart';

/// 登录态失效（401）时统一跳转登录页。
class AuthSessionGuard {
  AuthSessionGuard._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static bool _handling = false;

  static Future<void> handleUnauthorized({String? message}) async {
    if (_handling) return;
    _handling = true;
    try {
      await AppServices.I.session.clear();
      final nav = navigatorKey.currentState;
      if (nav == null) return;
      nav.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        (_) => false,
      );
      if (message != null && message.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = navigatorKey.currentContext;
          if (ctx != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        });
      }
    } finally {
      _handling = false;
    }
  }

  static bool shouldIgnorePath(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/login/mock');
  }
}
