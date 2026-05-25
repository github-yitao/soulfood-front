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

  Future<void> _retry() async {
    setState(() {
      _error = null;
      _ready = false;
    });
    await _start();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '启动失败',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF646871)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '请确认 Cloudflare 隧道和后端服务可用',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8D919A), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: _retry, child: const Text('重试')),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('DecideMeal 加载中…', style: TextStyle(color: Color(0xFF646871))),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
