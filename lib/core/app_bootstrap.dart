import 'package:flutter/material.dart';
import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/session/session_store.dart';
import 'package:soulfood_front/features/auth/auth_repository.dart';

class AppServices {
  AppServices._({
    required this.session,
    required this.api,
    required this.auth,
  });

  final SessionStore session;
  final ApiClient api;
  final AuthRepository auth;

  static AppServices? _instance;

  static AppServices get I {
    final instance = _instance;
    if (instance == null) {
      throw StateError('AppServices 未初始化，请先调用 AppBootstrap.init()');
    }
    return instance;
  }

  static Future<void> init() async {
    final session = SessionStore();
    await session.load();
    final api = ApiClient(session);
    final auth = AuthRepository(api, session);
    _instance = AppServices._(session: session, api: api, auth: auth);
    await auth.ensureLoggedIn();
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({required this.child, super.key});

  final Widget child;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await AppServices.init();
      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('启动失败：$_error\n\n请确认后端已启动且 baseUrl 正确'),
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return widget.child;
  }
}
