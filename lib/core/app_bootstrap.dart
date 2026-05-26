import 'package:flutter/material.dart';
import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/session/session_store.dart';
import 'package:soulfood_front/core/settings/app_icon_service.dart';
import 'package:soulfood_front/core/settings/app_locale.dart';
import 'package:soulfood_front/core/settings/appearance_store.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/features/auth/auth_repository.dart';

class AppServices {
  AppServices._({
    required this.session,
    required this.api,
    required this.auth,
    required this.appearance,
    required this.appearanceNotifier,
  });

  final SessionStore session;
  final ApiClient api;
  final AuthRepository auth;
  final AppearanceStore appearance;
  final ValueNotifier<AppearanceSettings> appearanceNotifier;

  /// 兼容旧引用
  ValueNotifier<AppThemeMode> get themeNotifier =>
      _ThemeModeProxy(appearanceNotifier);

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
    final appearance = AppearanceStore();
    await appearance.load();
    final api = ApiClient(session);
    final auth = AuthRepository(api, session);
    _instance = AppServices._(
      session: session,
      api: api,
      auth: auth,
      appearance: appearance,
      appearanceNotifier: ValueNotifier<AppearanceSettings>(
        appearance.settings,
      ),
    );
    await AppIconService.apply(appearance.settings.appIcon);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await appearance.saveMode(mode);
    appearanceNotifier.value = appearance.settings;
  }

  Future<void> setThemeVariant(AppThemeVariant variant) async {
    final icon = variant == AppThemeVariant.ghoul
        ? AppIconVariant.ghoul
        : AppIconVariant.classic;
    await appearance.saveVariant(variant);
    await appearance.saveAppIcon(icon);
    await AppIconService.apply(icon);
    appearanceNotifier.value = appearance.settings;
  }

  Future<void> setLocale(AppLocale locale) async {
    await appearance.saveLocale(locale);
    appearanceNotifier.value = appearance.settings;
  }

  Future<bool> setAppIcon(AppIconVariant icon) async {
    await appearance.saveAppIcon(icon);
    appearanceNotifier.value = appearance.settings;
    return AppIconService.apply(icon);
  }

  Future<void> setAppearance(AppearanceSettings settings) async {
    await appearance.save(settings);
    appearanceNotifier.value = appearance.settings;
  }
}

/// 让仍监听 themeNotifier 的页面继续工作。
class _ThemeModeProxy extends ValueNotifier<AppThemeMode> {
  _ThemeModeProxy(this._source) : super(_source.value.mode) {
    _source.addListener(_sync);
  }

  final ValueNotifier<AppearanceSettings> _source;

  void _sync() {
    value = _source.value.mode;
  }

  @override
  void dispose() {
    _source.removeListener(_sync);
    super.dispose();
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
      return _BootstrapShell(
        child: SafeArea(
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
      return const _BootstrapShell(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}

class _BootstrapShell extends StatelessWidget {
  const _BootstrapShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(color: const Color(0xFFF5F5F7), child: child),
    );
  }
}
