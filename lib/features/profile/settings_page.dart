import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/settings/appearance_store.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/app_theme_l10n.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/features/auth/login_page.dart';
import 'package:soulfood_front/features/profile/change_password_page.dart';
import 'package:soulfood_front/l10n/app_localizations.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _keyNotifications = 'settings_notifications_enabled';

  bool _notificationsEnabled = true;
  String _locationStatus = '检测中…';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _refreshLocationStatus();
    AppServices.I.appearanceNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppServices.I.appearanceNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true);
    }
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    if (mounted) setState(() => _notificationsEnabled = value);
  }

  Future<void> _refreshLocationStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _locationStatus = '未开启');
      return;
    }
    final permission = await Geolocator.checkPermission();
    final label = switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => '使用中',
      LocationPermission.denied => '未授权',
      LocationPermission.deniedForever => '已拒绝',
      _ => '未知',
    };
    if (mounted) setState(() => _locationStatus = label);
  }

  Future<void> _handleLocationTap() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.openAppSettings();
    }
    await _refreshLocationStatus();
  }

  String _themeModeLabel(AppLocalizations l10n, AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => l10n.themeModeLight,
        AppThemeMode.dark => l10n.themeModeDark,
        AppThemeMode.system => l10n.themeModeSystem,
      };

  String _appearanceLabel(AppLocalizations l10n) {
    final variant = AppServices.I.appearance.variant;
    if (variant == AppThemeVariant.ghoul) {
      return variant.labelOf(l10n);
    }
    return '${variant.labelOf(l10n)} · ${_themeModeLabel(l10n, AppServices.I.appearance.mode)}';
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('退出')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await AppServices.I.auth.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _showAccountSecurity() {
    final username = AppServices.I.session.username ?? '未登录';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('账号与安全', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('当前账号：$username', style: TextStyle(color: context.appColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline),
                title: const Text('修改密码'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const ChangePasswordPage()),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_android_outlined),
                title: const Text('绑定手机'),
                subtitle: const Text('用于找回密码', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.bindPhone);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('通知设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('接收推送通知'),
                subtitle: const Text('投票结果、好友邀请等消息提醒'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  _saveNotifications(value);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguage() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('语言设置'),
        content: const Text('当前仅支持简体中文，更多语言即将上线。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了')),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('帮助与反馈'),
        content: const Text(
          '如有问题或建议，欢迎通过应用商店评价或邮件联系我们：\n\nsupport@decidemeal.app',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeLabel = _appearanceLabel(l10n);
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: '账号与安全',
                onTap: _showAccountSecurity,
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: '通知设置',
                onTap: _showNotifications,
              ),
              _SettingsTile(
                icon: Icons.location_on_outlined,
                title: '位置权限',
                trailing: _locationStatus,
                onTap: _handleLocationTap,
              ),
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: '外观设置',
                trailing: themeLabel,
                onTap: () async {
                  await Navigator.pushNamed(context, AppRoutes.appearance);
                  if (mounted) setState(() {});
                },
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: '语言设置',
                trailing: '简体中文',
                onTap: _showLanguage,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                title: '帮助与反馈',
                onTap: _showHelp,
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: '关于 DecideMeal',
                trailing: 'v1.0.0',
                showChevron: false,
                onTap: () => Navigator.pushNamed(context, AppRoutes.about),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => _logout(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: colors.errorText,
              side: BorderSide(color: colors.errorBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('退出登录', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.cardBorder),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.showChevron = true,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: colors.textPrimary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing!, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          if (showChevron) ...[
            if (trailing != null) const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ],
      ),
    );
  }
}
