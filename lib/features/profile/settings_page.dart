import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/auth/login_page.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final username = AppServices.I.session.username;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          if (username != null)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('当前账号'),
              subtitle: Text(username),
            ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('外观设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.appearance),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于 DecideMeal'),
            trailing: const Text('v1.0.0'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _logout(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: const Color(0xFFE05252),
                side: const BorderSide(color: Color(0xFFE05252)),
              ),
              child: const Text('退出登录'),
            ),
          ),
        ],
      ),
    );
  }
}
