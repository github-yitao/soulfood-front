import 'package:flutter/material.dart';

/// 喰种主题标志性「赫眼」图形。
class GhoulEyeMark extends StatelessWidget {
  const GhoulEyeMark({
    super.key,
    this.size = 88,
    this.glow = true,
  });

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final outer = size;
    final iris = size * 0.42;
    final pupil = size * 0.16;

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (glow)
            Container(
              width: outer * 0.92,
              height: outer * 0.92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.45),
                    blurRadius: outer * 0.28,
                    spreadRadius: outer * 0.02,
                  ),
                ],
              ),
            ),
          Container(
            width: outer * 0.88,
            height: outer * 0.88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF2A2A2D), Color(0xFF0D0D0E)],
              ),
              border: Border.all(color: const Color(0xFF4A4A48), width: 1.5),
            ),
          ),
          Container(
            width: iris,
            height: iris,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFF6B63), Color(0xFFFF3B30), Color(0xFF8B0000)],
                stops: [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.6),
                  blurRadius: iris * 0.35,
                ),
              ],
            ),
          ),
          Container(
            width: pupil,
            height: pupil,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0A0A0A),
            ),
          ),
          Positioned(
            top: outer * 0.28,
            left: outer * 0.34,
            child: Container(
              width: outer * 0.08,
              height: outer * 0.08,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
