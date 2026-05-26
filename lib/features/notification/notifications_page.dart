import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/notification/notification_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _repo = NotificationRepository(AppServices.I.api);
  NotificationOverview? _overview;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _repo.load();
      if (mounted) setState(() => _overview = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openNotification(AppNotification item) async {
    if (!item.read) {
      try {
        await _repo.markRead(item.id);
      } catch (_) {
        // 已读失败不阻断跳转
      }
    }
    if (!mounted) return;
    if (item.roomCode != null && item.roomCode!.isNotEmpty) {
      await Navigator.pushNamed(context, AppRoutes.vote, arguments: item.roomCode);
    }
    await _load();
  }

  Future<void> _markAllRead() async {
    try {
      await _repo.markAllRead();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview;
    final unread = overview?.unreadCount ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息通知'),
        actions: [
          if (unread > 0)
            TextButton(onPressed: _markAllRead, child: const Text('全部已读')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: overview == null || overview.items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text(
                            '暂无通知',
                            style: TextStyle(color: Color(0xFF8D919A)),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: overview.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = overview.items[index];
                        return _NotificationTile(
                          item: item,
                          onTap: () => _openNotification(item),
                        );
                      },
                    ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.read ? Colors.white : const Color(0xFFFFF8F2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDF1F6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFBC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.type == 'room_closed' ? Icons.how_to_vote_outlined : Icons.notifications_outlined,
                  color: const Color(0xFFD86A00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F2430),
                              fontSize: item.read ? 14 : 15,
                            ),
                          ),
                        ),
                        if (!item.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE05252),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.body,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6F7888), height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.createdAt,
                      style: const TextStyle(fontSize: 12, color: Color(0xFFB3B8C2)),
                    ),
                  ],
                ),
              ),
              if (item.roomCode != null)
                const Icon(Icons.chevron_right, color: Color(0xFFB3B8C2)),
            ],
          ),
        ),
      ),
    );
  }
}
