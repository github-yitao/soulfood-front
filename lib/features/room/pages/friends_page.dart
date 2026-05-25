import 'package:flutter/material.dart';
import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/features/friend/friend_repository.dart';
import 'package:soulfood_front/features/room/room_models.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _friendRepo = FriendRepository();
  final _roomRepo = RoomRepository();

  bool _loading = true;
  String? _error;
  List<FriendItem> _friends = [];
  List<FriendRoom> _friendRooms = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _friendRepo.listFriends(),
        _roomRepo.listFriendRooms(),
      ]);
      if (!mounted) return;
      setState(() {
        _friends = results[0] as List<FriendItem>;
        _friendRooms = results[1] as List<FriendRoom>;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败，请下拉刷新重试';
        _loading = false;
      });
    }
  }

  Future<void> _joinFriendRoom(String code) async {
    try {
      await _roomRepo.joinRoom(code);
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.vote, arguments: code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      '和朋友一起决定',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ManageFriendsCard(
                friendCount: _friends.length,
                onTap: () => Navigator.pushNamed(context, AppRoutes.myFriends),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2E45), Color(0xFF35527D)],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '和朋友一起\n决定吃什么',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '添加好友后可看到对方进行中的房间，也可创建房间邀请投票。',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ActionCard(
                title: '发起一个新房间',
                subtitle: '自定义主题、人数和时长',
                primaryLabel: '创建房间',
                onPrimary: () => Navigator.pushNamed(context, AppRoutes.createRoom),
                secondaryLabel: '加入房间',
                onSecondary: () => Navigator.pushNamed(context, AppRoutes.joinRoom),
              ),
              const SizedBox(height: 12),
              const _VoteFlowHint(),
              const SizedBox(height: 8),
              _SectionHeader(title: '好友的房间', count: _friendRooms.length),
              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _ErrorHint(text: _error!, onRetry: _load)
              else if (_friendRooms.isEmpty)
                const _EmptyHint(text: '暂无好友进行中的房间\n好友创建房间后会出现在这里')
              else
                ..._friendRooms.map(
                  (room) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FriendRoomCard(
                      room: room,
                      onJoin: () => _joinFriendRoom(room.code),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _SectionHeader(title: '我的好友', count: _friends.length),
              const SizedBox(height: 8),
              if (!_loading && _error == null && _friends.isEmpty)
                _EmptyHint(
                  text: '还没有好友',
                  actionLabel: '去添加好友',
                  onAction: () => Navigator.pushNamed(context, AppRoutes.myFriends),
                )
              else if (!_loading && _error == null) ...[
                ..._friends.take(3).map(
                  (friend) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FriendTile(friend: friend),
                  ),
                ),
                if (_friends.length > 3)
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.myFriends),
                    child: Text('查看全部 ${_friends.length} 位好友'),
                  ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoteFlowHint extends StatelessWidget {
  const _VoteFlowHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF1F6)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('组局投票流程', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text(
            '1. 创建房间 → 复制房间号发给好友\n'
            '2. 大家进入投票页点选选项\n'
            '3. 底部点「结束投票，查看结果」→ 看胜出项 + AI 菜谱\n'
            '（创建后 30 分钟内有效，超时自动结束）',
            style: TextStyle(fontSize: 12, color: Color(0xFF6F7888), height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _ManageFriendsCard extends StatelessWidget {
  const _ManageFriendsCard({required this.friendCount, required this.onTap});

  final int friendCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFD4B8)),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF8F2), Color(0xFFFFFFFF)],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A43),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('添加 / 管理好友', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(
                      friendCount > 0 ? '已有 $friendCount 位好友，点此添加更多' : '输入邀请码添加好友，或注册时填邀请码',
                      style: const TextStyle(color: Color(0xFF6F7888), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF6F7888)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E6),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: const TextStyle(color: Color(0xFFFF8A43), fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _FriendRoomCard extends StatelessWidget {
  const _FriendRoomCard({required this.room, required this.onJoin});

  final FriendRoom room;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.topic, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${room.ownerNickname} · 房间号 ${room.code} · ${room.participantCount} 人参与',
                  style: const TextStyle(color: Color(0xFF6F7888), fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onJoin,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A43),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('进入'),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend});

  final FriendItem friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF1F6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8EEF7),
            backgroundImage: friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
                ? NetworkImage(friend.avatarUrl!)
                : null,
            child: friend.avatarUrl == null || friend.avatarUrl!.isEmpty
                ? Text(
                    friend.nickname.isNotEmpty ? friend.nickname.substring(0, 1) : '?',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF35527D)),
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
                  style: const TextStyle(color: Color(0xFF6F7888), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6F7888), fontSize: 13, height: 1.5),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8A43)),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorHint extends StatelessWidget {
  const _ErrorHint({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD6D6)),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB42318), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Color(0xFF6F7888), fontSize: 13)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A43),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(primaryLabel),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSecondary,
              child: Text(secondaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}
