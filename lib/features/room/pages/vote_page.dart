import 'package:flutter/material.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/room/pages/recipe_result_page.dart';
import 'package:soulfood_front/features/room/room_models.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/features/room/widgets/room_invite_card.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  final _repo = RoomRepository();
  final _agent = AgentRepository();
  RoomDetail? _room;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final room = await _repo.getRoom(widget.roomCode);
      if (mounted) setState(() => _room = room);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _vote(int optionId) async {
    setState(() => _submitting = true);
    try {
      final room = await _repo.vote(widget.roomCode, optionId);
      if (mounted) setState(() => _room = room);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _aiSuggest() async {
    final room = _room;
    if (room == null) return;
    setState(() => _submitting = true);
    try {
      final suggestions = await _agent.suggestOptions(
        topic: room.topic,
        existingOptions: room.options.map((o) => o.title).toList(),
      );
      for (final title in suggestions) {
        await _repo.addOption(widget.roomCode, title, source: 'ai');
      }
      final updated = await _repo.getRoom(widget.roomCode);
      if (mounted) {
        setState(() => _room = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已添加 ${suggestions.length} 个 AI 选项')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _addOption() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加选项'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '例如：寿司'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('添加'),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final room = await _repo.addOption(widget.roomCode, title);
      if (mounted) setState(() => _room = room);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _finish() async {
    final room = _room;
    if (room == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('结束投票？'),
        content: const Text(
          '结束后将统计票数并选出结果，房间将关闭，好友将无法继续投票。\n\n'
          '建议等好友都投完票后再结束。',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('再等一会')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8A43)),
            child: const Text('结束并查看结果'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      final result = await _repo.result(widget.roomCode);
      if (!mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => RecipeResultPage(
            voteResult: result,
            roomCode: widget.roomCode,
          ),
        ),
      );
      if (mounted) await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _viewResult() async {
    final room = _room;
    if (room == null) return;
    setState(() => _submitting = true);
    try {
      final result = _repo.resultFromDetail(room);
      if (!mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => RecipeResultPage(
            voteResult: result,
            roomCode: widget.roomCode,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    final isClosed = room?.status == 'closed';
    return Scaffold(
      appBar: AppBar(
        title: Text(room?.topic ?? '投票中'),
        actions: [
          IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading && room == null
            ? ListView(
                children: const [
                  SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                ],
              )
            : room == null
                ? ListView(
                    children: const [
                      SizedBox(height: 200, child: Center(child: Text('房间加载失败'))),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (!isClosed) RoomInviteCard(roomCode: room.code),
                      if (isClosed)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F9FC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            '投票已结束',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6F7888)),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        '${room.participantCount} 人已投票 · 状态 ${room.status}',
                        style: const TextStyle(color: Color(0xFF6F7888)),
                      ),
                      const SizedBox(height: 12),
                      ...room.options.map((opt) => _OptionCard(
                            option: opt,
                            selected: room.myVoteOptionId == opt.id,
                            onTap: isClosed || _submitting ? null : () => _vote(opt.id),
                          )),
                      if (!isClosed) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _submitting ? null : _aiSuggest,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('AI 补选项'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2B5EA8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _submitting ? null : _addOption,
                          icon: const Icon(Icons.add),
                          label: const Text('手动添加选项'),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _submitting ? null : _finish,
                          icon: const Icon(Icons.flag_rounded),
                          label: const Text('结束投票，查看结果'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A43),
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _submitting ? null : _viewResult,
                          icon: const Icon(Icons.restaurant_menu),
                          label: const Text('查看投票结果与菜谱'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A43),
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final RoomOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: selected ? const Color(0xFFD86A00) : const Color(0xFF1E1F23),
                      ),
                    ),
                  ),
                  Text('${option.percent}%'),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: option.percent / 100,
                backgroundColor: const Color(0xFFEFF2F6),
                color: const Color(0xFFFF8A43),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text('${option.voteCount} 票', style: const TextStyle(color: Color(0xFF8D919A), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
