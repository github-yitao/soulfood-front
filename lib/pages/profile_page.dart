import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/auth/auth_repository.dart';
import 'package:soulfood_front/features/favorite/favorites_page.dart';
import 'package:soulfood_front/features/order/orders_page.dart';
import 'package:soulfood_front/features/preference/preference_page.dart';
import 'package:soulfood_front/features/profile/profile_edit_page.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthRepository(AppServices.I.api, AppServices.I.session);
  late Future<UserProfile> _profileFuture = _auth.getProfile();

  Future<void> _reload() async {
    setState(() {
      _profileFuture = _auth.getProfile();
    });
    await _profileFuture;
  }

  void _open(Widget page) {
    Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('加载失败：${snapshot.error}'),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _reload, child: const Text('重试')),
                ],
              ),
            );
          }

          final profile = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  '我的',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      _ProfileAvatar(profile: profile),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.nickname,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            if (profile.username != null && profile.username!.isNotEmpty)
                              Text(
                                '@${profile.username}',
                                style: const TextStyle(color: Color(0xFF8D919A), fontSize: 13),
                              ),
                            Text(
                              profile.signature?.isNotEmpty == true
                                  ? profile.signature!
                                  : '让选择变得更简单',
                              style: const TextStyle(color: Color(0xFF8D919A)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: '编辑资料',
                        onPressed: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute<bool>(
                              builder: (_) => ProfileEditPage(profile: profile),
                            ),
                          );
                          if (updated == true) _reload();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _MenuCard(
                  items: [
                    _MenuItem(
                      icon: Icons.favorite_outline,
                      label: '我的收藏',
                      onTap: () => _open(const FavoritesPage()),
                    ),
                    _MenuItem(
                      icon: Icons.menu_book_outlined,
                      label: '菜品库',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.recipeLibrary),
                    ),
                    _MenuItem(
                      icon: Icons.restaurant_menu_outlined,
                      label: '我的口味偏好',
                      onTap: () => _open(const PreferencePage()),
                    ),
                    _MenuItem(
                      icon: Icons.receipt_long_outlined,
                      label: '历史订单',
                      onTap: () => _open(const OrdersPage()),
                    ),
                    _MenuItem(
                      icon: Icons.people_outline,
                      label: '我的好友',
                      trailing: '添加 / 管理',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.myFriends),
                    ),
                    _MenuItem(
                      icon: Icons.group_add_outlined,
                      label: '邀请好友',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.invite),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  items: [
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: '设置',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      label: '关于我们',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  items: [
                    _MenuItem(
                      icon: Icons.forum_outlined,
                      label: 'AI 对话记录',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.aiConversations),
                    ),
                    _MenuItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'AI 美食助手',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.aiChat, arguments: 'new'),
                    ),
                    _MenuItem(
                      icon: Icons.smart_toy_outlined,
                      label: 'AI 快捷推荐',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.aiQuick),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final url = profile.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundColor: const Color(0xFFFFEFBC),
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (_, _) {},
        child: url.isEmpty
            ? Text(
                profile.nickname.isNotEmpty ? profile.nickname.substring(0, 1) : '?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              )
            : null,
      );
    }
    return CircleAvatar(
      radius: 32,
      backgroundColor: const Color(0xFFFFEFBC),
      child: Text(
        profile.nickname.isNotEmpty ? profile.nickname.substring(0, 1) : '?',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 52),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5D6677)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing!, style: const TextStyle(color: Color(0xFFB3B8C2), fontSize: 12)),
          const Icon(Icons.chevron_right, color: Color(0xFFB3B8C2)),
        ],
      ),
      onTap: onTap,
    );
  }
}
