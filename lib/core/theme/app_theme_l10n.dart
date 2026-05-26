import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/l10n/app_localizations.dart';

extension AppThemeVariantL10n on AppThemeVariant {
  String labelOf(AppLocalizations l10n) => switch (this) {
        AppThemeVariant.classic => l10n.themeClassic,
        AppThemeVariant.ghoul => l10n.themeGhoul,
      };

  String descriptionOf(AppLocalizations l10n) => switch (this) {
        AppThemeVariant.classic => l10n.themeClassicDesc,
        AppThemeVariant.ghoul => l10n.themeGhoulDesc,
      };
}
