import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/friend/friend_repository.dart';
import 'package:soulfood_front/features/friend_chat/friend_chat_page.dart';
import 'package:soulfood_front/features/growth/invite_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';

/// 我的好友：列表 + 添加好友（独立页面，入口见「我的」与组局页）
class MyFriendsPage extends StatefulWidget {
  const MyFriendsPage({super.key});

  @override
  State<MyFriendsPage> createState() => _MyFriendsPageState();
}

class _MyFriendsPageState extends State<MyFriendsPage> {
  final _friendRepo = FriendRepository();
  final _inviteRepo = InviteRepository();
  final _codeCtrl = TextEditingController();

  bool _loading = true;
  bool _adding = false;
  String? _error;
  List<FriendItem> _friends = [];
  String? _myInviteCode;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _friendRepo.listFriends(),
        _inviteRepo.loadOverview(),
      ]);
      if (!mounted) return;
      setState(() {
        _friends = results[0] as List<FriendItem>;
        _myInviteCode = (results[1] as InviteOverview).inviteCode;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败，请下拉刷新';
        _loading = false;
      });
    }
  }

  Future<void> _addFriend() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入对方的邀请码')));
      return;
    }
    setState(() => _adding = true);
    try {
      await _friendRepo.addFriend(code);
      if (!mounted) return;
      _codeCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已添加好友')));
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _copyMyCode() async {
    final code = _myInviteCode;
    if (code == null || code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('我的邀请码已复制')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的好友'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.friends),
            child: const Text('组局投票'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _AddFriendCard(
              controller: _codeCtrl,
              loading: _adding,
              onAdd: _addFriend,
            ),
            if (_myInviteCode != null && _myInviteCode!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MyCodeCard(code: _myInviteCode!, onCopy: _copyMyCode),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('好友列表', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                if (!_loading)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: appStatusDecoration(colors, AppStatusKind.warning),
                    child: Text(
                      '${_friends.length}',
                      style: TextStyle(
                        color: colors.warningText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _HintBox(
                text: _error!,
                isError: true,
                actionLabel: '重试',
                onAction: _load,
              )
            else if (_friends.isEmpty)
              const _HintBox(
                text: '还没有好友\n\n方式一：在上方输入对方邀请码添加\n方式二：注册时填写对方邀请码自动成为好友',
              )
            else
              ..._friends.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _FriendTile(
                    friend: f,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.friendChat,
                      arguments: FriendChatArgs(
                        friendUserId: f.userId,
                        nickname: f.nickname,
                        avatarUrl: f.avatarUrl,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AddFriendCard extends StatelessWidget {
  const _AddFriendCard({
    required this.controller,
    required this.loading,
    required this.onAdd,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(context, radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.chipSelectedBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_add_alt_1_rounded, color: colors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('添加好友', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(
                      '输入对方邀请码（如 DM123456）',
                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: '对方邀请码',
              hintText: 'DM123456',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onAdd(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading ? null : onAdd,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.onAccent),
                    )
                  : const Text('确认添加'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyCodeCard extends StatelessWidget {
  const _MyCodeCard({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: appMutedSurfaceDecoration(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的邀请码（发给朋友让对方添加你）',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ],
            ),
          ),
          OutlinedButton(onPressed: onCopy, child: const Text('复制')),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend, this.onTap});

  final FriendItem friend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: appCardDecoration(context, radius: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.infoBackground,
                backgroundImage: friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
                    ? NetworkImage(friend.avatarUrl!)
                    : null,
                child: friend.avatarUrl == null || friend.avatarUrl!.isEmpty
                    ? Text(
                        friend.nickname.isNotEmpty ? friend.nickname.substring(0, 1) : '?',
                        style: TextStyle(fontWeight: FontWeight.w700, color: colors.infoText),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friend.nickname, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(
                      '${friend.sourceLabel} · ${friend.addedAt}',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chat_bubble_outline_rounded, size: 20, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox({
    required this.text,
    this.isError = false,
    this.actionLabel,
    this.onAction,
  });

  final String text;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: isError
          ? appStatusDecoration(colors, AppStatusKind.error)
          : appMutedSurfaceDecoration(context),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isError ? colors.errorText : colors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
