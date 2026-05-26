import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';

class VoteOptionThumbStyle {
  const VoteOptionThumbStyle({required this.icon, required this.colors});

  final IconData icon;
  final List<Color> colors;
}

VoteOptionThumbStyle voteOptionThumbStyle(String title, {String source = 'manual'}) {
  final t = title.toLowerCase();
  if (t.contains('火锅') || t.contains('hotpot')) {
    return const VoteOptionThumbStyle(
      icon: Icons.soup_kitchen_rounded,
      colors: [Color(0xFFFF8C60), Color(0xFFFF4D4F)],
    );
  }
  if (t.contains('烤') || t.contains('bbq')) {
    return const VoteOptionThumbStyle(
      icon: Icons.outdoor_grill_rounded,
      colors: [Color(0xFF686B73), Color(0xFF1F232B)],
    );
  }
  if (t.contains('面') || t.contains('粉') || t.contains('noodle')) {
    return const VoteOptionThumbStyle(
      icon: Icons.ramen_dining_rounded,
      colors: [Color(0xFF8ECF89), Color(0xFF54A365)],
    );
  }
  if (t.contains('番茄') || t.contains('tomato')) {
    return const VoteOptionThumbStyle(
      icon: Icons.egg_alt_outlined,
      colors: [Color(0xFFFF9B60), Color(0xFFF45F5F)],
    );
  }
  if (source == 'ai') {
    return const VoteOptionThumbStyle(
      icon: Icons.auto_awesome_rounded,
      colors: [Color(0xFF8EB5FF), Color(0xFF2B5EA8)],
    );
  }
  return const VoteOptionThumbStyle(
    icon: Icons.restaurant_rounded,
    colors: [Color(0xFFF3BD57), Color(0xFFDB8F36)],
  );
}

class VoteOptionThumb extends StatelessWidget {
  const VoteOptionThumb({required this.title, this.source = 'manual', super.key});

  final String title;
  final String source;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = voteOptionThumbStyle(title, source: source);
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.colors,
        ),
      ),
      child: Icon(style.icon, color: colors.onAccent, size: 28),
    );
  }
}
