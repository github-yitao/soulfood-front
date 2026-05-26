import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/auth/register_page.dart';
import 'package:soulfood_front/features/room/room_deep_link.dart';
import 'package:soulfood_front/pages/root_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入账号和密码')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AppServices.I.auth.login(username: username, password: password);
      if (!mounted) return;
      final joined = await RoomDeepLinkListener.tryConsumePendingJoin(context);
      if (!mounted || joined) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const RootPage()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 48),
            const Text(
              '欢迎回来',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              '使用账号密码登录 DecideMeal',
              style: TextStyle(color: Color(0xFF8D919A)),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: '账号',
                hintText: '3-32 位字母或数字',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: '密码',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _loading ? null : _login(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _login,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFFFF8A43),
              ),
              child: Text(_loading ? '登录中…' : '登录'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
                      ),
              child: const Text('没有账号？立即注册'),
            ),
          ],
        ),
      ),
    );
  }
}
