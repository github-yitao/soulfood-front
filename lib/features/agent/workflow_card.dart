import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';

class WorkflowCard extends StatelessWidget {
  const WorkflowCard({
    super.key,
    required this.snapshot,
    this.onContinue,
    this.onSkip,
  });

  final WorkflowSnapshot snapshot;
  final VoidCallback? onContinue;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.infoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                snapshot.status == 'failed'
                    ? Icons.error_outline
                    : Icons.account_tree_outlined,
                size: 16,
                color: snapshot.status == 'failed'
                    ? colors.errorText
                    : colors.infoText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  snapshot.title.isEmpty ? '处理中' : snapshot.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                _statusLabel(snapshot.status),
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...snapshot.steps.map((step) => _StepRow(step: step)),
          if ((onContinue != null || onSkip != null) &&
              snapshot.status == 'waiting')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (onContinue != null)
                    FilledButton.tonal(
                      onPressed: onContinue,
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(_continueLabel(snapshot)),
                    ),
                  if (onSkip != null)
                    OutlinedButton(
                      onPressed: onSkip,
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('不拍图 / 按食材'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'done' => '已完成',
      'failed' => '失败',
      'waiting' => '待确认',
      _ => '进行中',
    };
  }

  static String _continueLabel(WorkflowSnapshot snapshot) {
    final waiting = snapshot.steps.where((step) => step.status == 'waiting');
    final id = waiting.isEmpty ? '' : waiting.first.id;
    return switch (id) {
      'vision' => '拍照 / 看图继续',
      'locate' => '已开启定位，继续',
      'collect_options' => '确认并创建房间',
      _ => '继续流程',
    };
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final WorkflowStep step;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (icon, color) = switch (step.status) {
      'done' => (Icons.check_circle, colors.successText),
      'failed' => (Icons.cancel, colors.errorText),
      'waiting' => (Icons.pause_circle_outline, colors.warningText),
      'running' => (Icons.timelapse, colors.infoText),
      _ => (Icons.radio_button_unchecked, colors.textSecondary),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(fontSize: 12.5, color: colors.textPrimary),
                ),
                if (step.summary != null && step.summary!.isNotEmpty)
                  Text(
                    step.summary!,
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
