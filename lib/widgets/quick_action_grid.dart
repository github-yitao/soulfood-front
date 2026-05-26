import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';

class QuickAction {
  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
}

/// 2×2 快捷入口，用于记录页等。
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.35,
      children: actions.map((action) => _QuickActionTile(action: action, colors: colors)).toList(),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, required this.colors});

  final QuickAction action;
  final AppSemanticColors colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            children: [
              Icon(action.icon, size: 22, color: colors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  action.label,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: colors.textPrimary),
                ),
              ),
              if (action.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    action.badge!,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.accent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
