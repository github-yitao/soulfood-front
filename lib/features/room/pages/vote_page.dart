import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/room/pages/recipe_result_page.dart';
import 'package:soulfood_front/features/room/room_models.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/features/room/widgets/room_invite_card.dart';

/// 组局投票：选选项 → 好友加入 → 结束看结果
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
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _enterRoom();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _syncCountdown(RoomDetail room) {
    _remainingSeconds = room.remainingSeconds;
    _countdownTimer?.cancel();
    if (room.isClosed || _remainingSeconds <= 0) {
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _countdownTimer?.cancel();
        _enterRoom();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  String get _remainingLabel {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _enterRoom() async {
    setState(() => _loading = true);
    try {
      await _repo.joinRoom(widget.roomCode);
      final room = await _repo.getRoom(widget.roomCode);
      if (mounted) {
        setState(() => _room = room);
        _syncCountdown(room);
        if (room.isClosed && room.remainingSeconds == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('投票已超时自动结束（30分钟）')),
          );
        }
      }
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
      if (!mounted) return;
      setState(() => _room = room);
      _syncCountdown(room);
      final picked = room.options.where((o) => o.id == optionId).map((o) => o.title).firstOrNull;
      if (picked != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已投票：$picked')),
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
    if (_room == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('结束投票？'),
        content: const Text(
          '结束后将统计票数、关闭房间，并进入结果页。\n好友将无法继续投票。',
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
      if (mounted) await _enterRoom();
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

  String? get _myPickTitle {
    final room = _room;
    if (room == null || room.myVoteOptionId == null) return null;
    return room.options
        .where((o) => o.id == room.myVoteOptionId)
        .map((o) => o.title)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    final isClosed = room?.status == 'closed';
    final hasVoted = room?.myVoteOptionId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(room?.topic ?? '组局投票'),
        actions: [
          IconButton(onPressed: _loading ? null : _enterRoom, icon: const Icon(Icons.refresh)),
        ],
      ),
      bottomNavigationBar: room == null || _loading
          ? null
          : _VoteBottomBar(
              isClosed: isClosed,
              hasVoted: hasVoted,
              submitting: _submitting,
              onFinish: _finish,
              onViewResult: _viewResult,
            ),
      body: _loading && room == null
          ? const Center(child: CircularProgressIndicator())
          : room == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('房间加载失败'),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _enterRoom, child: const Text('重试')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _enterRoom,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      _VoteFlowSteps(isClosed: isClosed, hasVoted: hasVoted),
                      const SizedBox(height: 12),
                      if (!isClosed && _remainingSeconds > 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: _remainingSeconds <= 300
                                ? const Color(0xFFFFF5F5)
                                : const Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _remainingSeconds <= 300
                                  ? const Color(0xFFFFD6D6)
                                  : const Color(0xFFB8D4F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 18,
                                color: _remainingSeconds <= 300
                                    ? const Color(0xFFB42318)
                                    : const Color(0xFF2B5EA8),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '剩余 $_remainingLabel · 超时后自动结束（最长30分钟）',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _remainingSeconds <= 300
                                        ? const Color(0xFFB42318)
                                        : const Color(0xFF2B5EA8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!isClosed) RoomInviteCard(roomCode: room.code, compact: true),
                      if (isClosed)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFB7DFC0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '投票已结束（手动结束或超过30分钟自动结束）',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_myPickTitle != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '你的选择：$_myPickTitle',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD86A00),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        '${room.participantCount} 人已投票',
                        style: const TextStyle(color: Color(0xFF6F7888), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '点选一项即完成投票（可改选）',
                        style: TextStyle(color: Color(0xFF8D919A), fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      ...room.options.map(
                        (opt) => _OptionCard(
                          option: opt,
                          selected: room.myVoteOptionId == opt.id,
                          onTap: isClosed || _submitting ? null : () => _vote(opt.id),
                        ),
                      ),
                      if (!isClosed) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _submitting ? null : _aiSuggest,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('AI 补选项'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _submitting ? null : _addOption,
                          icon: const Icon(Icons.add),
                          label: const Text('手动添加选项'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _VoteFlowSteps extends StatelessWidget {
  const _VoteFlowSteps({required this.isClosed, required this.hasVoted});

  final bool isClosed;
  final bool hasVoted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _StepDot(label: '1', title: '选选项', active: !hasVoted && !isClosed, done: hasVoted || isClosed),
          _StepLine(done: hasVoted || isClosed),
          _StepDot(label: '2', title: '好友加入', active: hasVoted && !isClosed, done: isClosed),
          _StepLine(done: isClosed),
          _StepDot(label: '3', title: '结束看结果', active: isClosed, done: isClosed),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.title,
    required this.active,
    required this.done,
  });

  final String label;
  final String title;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? const Color(0xFF2E7D32)
        : active
            ? const Color(0xFFFF8A43)
            : const Color(0xFFB3B8C2);
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 12)),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: done ? const Color(0xFF2E7D32) : const Color(0xFFE0E4EA),
      ),
    );
  }
}

class _VoteBottomBar extends StatelessWidget {
  const _VoteBottomBar({
    required this.isClosed,
    required this.hasVoted,
    required this.submitting,
    required this.onFinish,
    required this.onViewResult,
  });

  final bool isClosed;
  final bool hasVoted;
  final bool submitting;
  final VoidCallback onFinish;
  final VoidCallback onViewResult;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: isClosed
            ? FilledButton.icon(
                onPressed: submitting ? null : onViewResult,
                icon: const Icon(Icons.emoji_events_outlined),
                label: const Text('查看投票结果与菜谱'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A43),
                  minimumSize: const Size.fromHeight(50),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasVoted)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '请先点选一个选项完成投票',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF8D919A), fontSize: 12),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: submitting ? null : onFinish,
                    icon: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.flag_rounded),
                    label: const Text('结束投票，查看结果'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A43),
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? const Color(0xFFFF8A43) : Colors.transparent,
          width: 2,
        ),
      ),
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
                  if (selected)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check_circle, color: Color(0xFFFF8A43), size: 20),
                    ),
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
