import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/classic_brand_palette.dart';

/// 经典主题标识：简约线型图标，无自定义插画。
class ClassicBrandMark extends StatelessWidget {
  const ClassicBrandMark({
    super.key,
    this.size = 48,
    this.color,
    this.filled = false,
  });

  final double size;
  final Color? color;
  /// true 时使用实心圆底 + 白色图标（启动页等）
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? ClassicBrandPalette.accent;
    final icon = Icon(
      Icons.restaurant_menu_rounded,
      size: size * 0.52,
      color: filled ? Colors.white : tint,
    );

    if (!filled) return icon;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(child: icon),
    );
  }
}
