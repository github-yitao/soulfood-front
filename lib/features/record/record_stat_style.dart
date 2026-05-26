import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';

class RecordStatStyle {
  const RecordStatStyle({required this.background, required this.titleColor});

  final Color background;
  final Color titleColor;
}

/// 记录页统计卡片配色，浅色用柔和粉彩，暗色/喰种用语义色。
RecordStatStyle recordStatStyle(BuildContext context, String key) {
  final colors = context.appColors;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  if (!isDark) {
    return switch (key) {
      'vote' => const RecordStatStyle(
          background: Color(0xFFFFD6D7),
          titleColor: Color(0xFFF05F65),
        ),
      'friends' => const RecordStatStyle(
          background: Color(0xFFFFEFBC),
          titleColor: Color(0xFFE0AF28),
        ),
      'eat' => const RecordStatStyle(
          background: Color(0xFFDDF6DF),
          titleColor: Color(0xFF48B86B),
        ),
      'favorite' => const RecordStatStyle(
          background: Color(0xFFE0E6FF),
          titleColor: Color(0xFF7E8BDF),
        ),
      _ => RecordStatStyle(
          background: colors.chipBackground,
          titleColor: colors.textSecondary,
        ),
    };
  }

  return switch (key) {
    'vote' => RecordStatStyle(
        background: colors.errorBackground,
        titleColor: colors.errorText,
      ),
    'friends' => RecordStatStyle(
        background: colors.warningBackground,
        titleColor: colors.warningText,
      ),
    'eat' => RecordStatStyle(
        background: colors.successBackground,
        titleColor: colors.successText,
      ),
    'favorite' => RecordStatStyle(
        background: colors.infoBackground,
        titleColor: colors.infoText,
      ),
    _ => RecordStatStyle(
        background: colors.chipBackground,
        titleColor: colors.textSecondary,
      ),
  };
}
