import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/room/room_deep_link.dart';
import 'package:soulfood_front/pages/root_page.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _inviteCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _agreed = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _nicknameCtrl.dispose();
    _inviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先阅读并同意用户协议与隐私政策')),
      );
      return;
    }
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.length < 3 || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('账号至少 3 位，密码至少 6 位')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AppServices.I.auth.register(
        username: username,
        password: password,
        nickname: _nicknameCtrl.text.trim(),
        inviteCode: _inviteCtrl.text.trim(),
      );
      if (!mounted) return;
      final joined = await RoomDeepLinkListener.tryConsumePendingJoin(context);
      if (!mounted || joined) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const RootPage()),
        (_) => false,
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
      appBar: AppBar(title: const Text('注册账号')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(
              labelText: '账号',
              border: OutlineInputBorder(),
            ),
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
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nicknameCtrl,
            decoration: const InputDecoration(
              labelText: '昵称（可选）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inviteCtrl,
            decoration: const InputDecoration(
              labelText: '邀请码（可选）',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
              ),
              Expanded(
                child: Wrap(
                  children: [
                    const Text('我已阅读并同意'),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.legalTerms),
                      child: const Text(
                        '《用户协议》',
                        style: TextStyle(color: Color(0xFF2B5EA8), fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Text('和'),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.legalPrivacy),
                      child: const Text(
                        '《隐私政策》',
                        style: TextStyle(color: Color(0xFF2B5EA8), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _register,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: const Color(0xFFFF8A43),
            ),
            child: Text(_loading ? '注册中…' : '注册并登录'),
          ),
        ],
      ),
    );
  }
}
