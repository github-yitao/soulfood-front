import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/settings/appearance_store.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/core/theme/ghoul_eye_mark.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  late AppearanceSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = AppServices.I.appearance.settings;
  }

  Future<void> _selectVariant(AppThemeVariant variant) async {
    setState(() => _settings = AppearanceSettings(variant: variant, mode: _settings.mode));
    await AppServices.I.setThemeVariant(variant);
  }

  Future<void> _selectMode(AppThemeMode mode) async {
    setState(() => _settings = AppearanceSettings(variant: _settings.variant, mode: mode));
    await AppServices.I.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isGhoul = _settings.variant == AppThemeVariant.ghoul;

    return Scaffold(
      appBar: AppBar(title: const Text('外观设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('主题风格', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.textPrimary)),
          const SizedBox(height: 12),
          _VariantCard(
            variant: AppThemeVariant.classic,
            selected: _settings.variant == AppThemeVariant.classic,
            onTap: () => _selectVariant(AppThemeVariant.classic),
          ),
          const SizedBox(height: 10),
          _VariantCard(
            variant: AppThemeVariant.ghoul,
            selected: _settings.variant == AppThemeVariant.ghoul,
            onTap: () => _selectVariant(AppThemeVariant.ghoul),
          ),
          const SizedBox(height: 24),
          Text(
            '明暗模式',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isGhoul ? colors.textSecondary : colors.textPrimary,
            ),
          ),
          if (isGhoul) ...[
            const SizedBox(height: 8),
            Text(
              '喰种暗红主题为固定暗色风格',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          _ModeTile(
            label: '浅色模式',
            enabled: !isGhoul,
            selected: _settings.mode == AppThemeMode.light,
            onTap: () => _selectMode(AppThemeMode.light),
          ),
          _ModeTile(
            label: '深色模式',
            enabled: !isGhoul,
            selected: _settings.mode == AppThemeMode.dark,
            onTap: () => _selectMode(AppThemeMode.dark),
          ),
          _ModeTile(
            label: '跟随系统',
            enabled: !isGhoul,
            selected: _settings.mode == AppThemeMode.system,
            onTap: () => _selectMode(AppThemeMode.system),
          ),
          const SizedBox(height: 16),
          Text(
            '主题设置仅在当前设备生效',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  final AppThemeVariant variant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isGhoul = variant == AppThemeVariant.ghoul;

    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.accent : colors.cardBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _ThemePreviewMini(variant: variant),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      variant.description,
                      style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.35),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: colors.accent)
              else if (isGhoul)
                Icon(Icons.nightlight_round, color: colors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreviewMini extends StatelessWidget {
  const _ThemePreviewMini({required this.variant});

  final AppThemeVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == AppThemeVariant.ghoul) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF1C1C1E),
          border: Border.all(color: const Color(0xFF4A4A48)),
        ),
        child: const Center(child: GhoulEyeMark(size: 36, glow: false)),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD36E), Color(0xFFFF9F5A)],
        ),
      ),
      child: const Icon(Icons.ramen_dining, color: Colors.white),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: enabled,
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: enabled ? colors.textPrimary : colors.textSecondary,
          ),
        ),
        trailing: selected && enabled ? Icon(Icons.check_circle, color: colors.accent) : null,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
