import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';

enum AppStatusKind { success, error, info, warning }

/// 通用卡片装饰，替代硬编码 `Colors.white`。
BoxDecoration appCardDecoration(
  BuildContext context, {
  bool selected = false,
  double radius = 16,
  Color? borderColor,
}) {
  final colors = context.appColors;
  return BoxDecoration(
    color: colors.cardBackground,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: borderColor ?? (selected ? colors.accent : colors.cardBorder),
      width: selected ? 1.5 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: colors.textPrimary.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

BoxDecoration appMutedSurfaceDecoration(BuildContext context, {double radius = 14}) {
  final colors = context.appColors;
  return BoxDecoration(
    color: colors.chipBackground,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: colors.chipBorder),
  );
}

BoxDecoration appStatusDecoration(AppSemanticColors colors, AppStatusKind kind) {
  return switch (kind) {
    AppStatusKind.success => BoxDecoration(
        color: colors.successBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.successBorder),
      ),
    AppStatusKind.error => BoxDecoration(
        color: colors.errorBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.errorBorder),
      ),
    AppStatusKind.info => BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.infoBorder),
      ),
    AppStatusKind.warning => BoxDecoration(
        color: colors.warningBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.warningBorder),
      ),
  };
}

Color appStatusTextColor(AppSemanticColors colors, AppStatusKind kind) {
  return switch (kind) {
    AppStatusKind.success => colors.successText,
    AppStatusKind.error => colors.errorText,
    AppStatusKind.info => colors.infoText,
    AppStatusKind.warning => colors.warningText,
  };
}

/// 与主题一致的卡片容器，替代硬编码 `Colors.white`。
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.textPrimary),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ],
          if (title != null || subtitle != null) const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// 品类/标签筛选 Chip，自动跟随主题。
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.showCheckmark = true,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final bool showCheckmark;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: showCheckmark,
      onSelected: onSelected,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: selected ? colors.chipSelectedText : colors.chipText,
      ),
      backgroundColor: colors.chipBackground,
      selectedColor: colors.chipSelectedBackground,
      checkmarkColor: colors.chipSelectedText,
      side: BorderSide(color: selected ? colors.chipSelectedBorder : colors.chipBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

BoxDecoration appInviteCardDecoration(BuildContext context) {
  final colors = context.appColors;
  return BoxDecoration(
    color: colors.inviteCardBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: colors.inviteCardBorder),
  );
}
