import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/settings/app_icon_service.dart';
import 'package:soulfood_front/core/settings/app_locale.dart';
import 'package:soulfood_front/core/settings/appearance_store.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/app_theme_l10n.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/core/theme/classic_brand_mark.dart';
import 'package:soulfood_front/core/theme/classic_brand_palette.dart';
import 'package:soulfood_front/core/theme/ghoul_eye_mark.dart';
import 'package:soulfood_front/l10n/app_localizations.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  late AppearanceSettings _settings;
  bool _iconSupported = false;

  @override
  void initState() {
    super.initState();
    _settings = AppServices.I.appearance.settings;
    _checkIconSupport();
  }

  Future<void> _checkIconSupport() async {
    final supported = await AppIconService.isSupported;
    if (mounted) setState(() => _iconSupported = supported);
  }

  Future<void> _selectVariant(AppThemeVariant variant) async {
    setState(() => _settings = _settings.copyWith(variant: variant));
    await AppServices.I.setThemeVariant(variant);
  }

  Future<void> _selectMode(AppThemeMode mode) async {
    setState(() => _settings = _settings.copyWith(mode: mode));
    await AppServices.I.setThemeMode(mode);
  }

  Future<void> _selectLocale(AppLocale locale) async {
    setState(() => _settings = _settings.copyWith(locale: locale));
    await AppServices.I.setLocale(locale);
  }

  Future<void> _selectAppIcon(AppIconVariant icon) async {
    setState(() => _settings = _settings.copyWith(appIcon: icon));
    final ok = await AppServices.I.setAppIcon(icon);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? l10n.appIconChanged : l10n.appIconUnsupported)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;
    final isGhoul = _settings.variant == AppThemeVariant.ghoul;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearance)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.themeStyle, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.textPrimary)),
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
            l10n.themeMode,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isGhoul ? colors.textSecondary : colors.textPrimary,
            ),
          ),
          if (isGhoul) ...[
            const SizedBox(height: 8),
            Text(l10n.ghoulModeFixed, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          ],
          const SizedBox(height: 12),
          _ModeTile(
            label: l10n.themeModeLight,
            enabled: !isGhoul,
            selected: _settings.mode == AppThemeMode.light,
            onTap: () => _selectMode(AppThemeMode.light),
          ),
          _ModeTile(
            label: l10n.themeModeDark,
            enabled: !isGhoul,
            selected: _settings.mode == AppThemeMode.dark,
            onTap: () => _selectMode(AppThemeMode.dark),
          ),
          _ModeTile(
            label: l10n.themeModeSystem,
            enabled: !isGhoul,
            selected: _settings.mode == AppThemeMode.system,
            onTap: () => _selectMode(AppThemeMode.system),
          ),
          const SizedBox(height: 24),
          Text(l10n.language, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.textPrimary)),
          const SizedBox(height: 12),
          _ModeTile(
            label: l10n.languageZh,
            selected: _settings.locale == AppLocale.zh,
            onTap: () => _selectLocale(AppLocale.zh),
          ),
          _ModeTile(
            label: l10n.languageEn,
            selected: _settings.locale == AppLocale.en,
            onTap: () => _selectLocale(AppLocale.en),
          ),
          const SizedBox(height: 24),
          Text(l10n.appIcon, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.textPrimary)),
          if (!_iconSupported) ...[
            const SizedBox(height: 8),
            Text(l10n.appIconUnsupported, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          ],
          const SizedBox(height: 12),
          _ModeTile(
            label: l10n.appIconClassic,
            enabled: _iconSupported,
            selected: _settings.appIcon == AppIconVariant.classic,
            onTap: () => _selectAppIcon(AppIconVariant.classic),
          ),
          _ModeTile(
            label: l10n.appIconGhoul,
            enabled: _iconSupported,
            selected: _settings.appIcon == AppIconVariant.ghoul,
            onTap: () => _selectAppIcon(AppIconVariant.ghoul),
          ),
          const SizedBox(height: 16),
          Text(l10n.appearanceLocalOnly, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
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
    final l10n = AppLocalizations.of(context)!;
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
                      variant.labelOf(l10n),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      variant.descriptionOf(l10n),
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
    final colors = context.appColors;
    if (variant == AppThemeVariant.ghoul) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colors.heroGradientStart,
          border: Border.all(color: colors.cardBorder),
        ),
        child: Center(child: GhoulEyeMark(size: 36, glow: false)),
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
          colors: ClassicBrandPalette.heroGradient,
        ),
        border: Border.all(color: const Color(0xFFFFC98A)),
        boxShadow: [
          BoxShadow(
            color: ClassicBrandPalette.accent.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(child: ClassicBrandMark(size: 38, showPlate: false, glow: false)),
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
