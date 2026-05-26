import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/auth/auth_repository.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _signatureCtrl;
  late final TextEditingController _avatarCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl = TextEditingController(text: widget.profile.nickname);
    _signatureCtrl = TextEditingController(text: widget.profile.signature ?? '');
    _avatarCtrl = TextEditingController(text: widget.profile.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _signatureCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nickname = _nicknameCtrl.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('昵称不能为空')));
      return;
    }
    setState(() => _saving = true);
    try {
      await AppServices.I.auth.updateProfile(
        nickname: nickname,
        signature: _signatureCtrl.text.trim(),
        avatarUrl: _avatarCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '保存中…' : '保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nicknameCtrl,
            decoration: const InputDecoration(
              labelText: '昵称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _signatureCtrl,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: '个性签名',
              border: OutlineInputBorder(),
              hintText: '让选择变得更简单',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _avatarCtrl,
            decoration: const InputDecoration(
              labelText: '头像链接（可选）',
              border: OutlineInputBorder(),
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '头像暂支持粘贴图片 URL，本地上传后续开放。',
            style: TextStyle(color: Color(0xFF8D919A), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
