import 'package:flutter/material.dart';
import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/friend/friend_repository.dart';

/// 选择一位好友（用于分享等场景）。
class FriendPickerSheet {
  FriendPickerSheet._();

  static Future<FriendItem?> pick(BuildContext context) {
    return showModalBottomSheet<FriendItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _FriendPickerBody(),
    );
  }
}

class _FriendPickerBody extends StatefulWidget {
  const _FriendPickerBody();

  @override
  State<_FriendPickerBody> createState() => _FriendPickerBodyState();
}

class _FriendPickerBodyState extends State<_FriendPickerBody> {
  final _repo = FriendRepository();
  bool _loading = true;
  String? _error;
  List<FriendItem> _friends = [];

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
      final friends = await _repo.listFriends();
      if (!mounted) return;
      setState(() {
        _friends = friends;
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
        _error = '加载好友失败';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
  final maxHeight = MediaQuery.sizeOf(context).height * 0.55;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('选择好友', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _error != null
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, style: TextStyle(color: colors.errorText)),
                              const SizedBox(height: 12),
                              OutlinedButton(onPressed: _load, child: const Text('重试')),
                            ],
                          ),
                        )
                      : _friends.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                '还没有好友，先去添加好友吧',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: _friends.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final friend = _friends[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context, friend),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: appCardDecoration(context, radius: 14),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: colors.infoBackground,
                                            backgroundImage: friend.avatarUrl != null &&
                                                    friend.avatarUrl!.isNotEmpty
                                                ? NetworkImage(friend.avatarUrl!)
                                                : null,
                                            child: friend.avatarUrl == null || friend.avatarUrl!.isEmpty
                                                ? Text(
                                                    friend.nickname.isNotEmpty
                                                        ? friend.nickname.substring(0, 1)
                                                        : '?',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      color: colors.infoText,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              friend.nickname,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.chevron_right, color: colors.textSecondary),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
