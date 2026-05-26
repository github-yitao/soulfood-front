import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'DecideMeal'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get tabHome;

  /// No description provided for @tabRecords.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get tabRecords;

  /// No description provided for @tabMine.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabMine;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In zh, this message translates to:
  /// **'外观设置'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @languageZh.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get languageZh;

  /// No description provided for @languageEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @themeClassic.
  ///
  /// In zh, this message translates to:
  /// **'经典暖色'**
  String get themeClassic;

  /// No description provided for @themeGhoul.
  ///
  /// In zh, this message translates to:
  /// **'喰种暗红'**
  String get themeGhoul;

  /// No description provided for @themeModeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeModeSystem;

  /// No description provided for @appIcon.
  ///
  /// In zh, this message translates to:
  /// **'应用图标'**
  String get appIcon;

  /// No description provided for @appIconClassic.
  ///
  /// In zh, this message translates to:
  /// **'默认图标'**
  String get appIconClassic;

  /// No description provided for @appIconGhoul.
  ///
  /// In zh, this message translates to:
  /// **'喰种图标'**
  String get appIconGhoul;

  /// No description provided for @appIconChanged.
  ///
  /// In zh, this message translates to:
  /// **'应用图标已切换'**
  String get appIconChanged;

  /// No description provided for @appIconUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'当前设备暂不支持动态切换图标'**
  String get appIconUnsupported;

  /// No description provided for @nearbyTitle.
  ///
  /// In zh, this message translates to:
  /// **'附近觅食'**
  String get nearbyTitle;

  /// No description provided for @nearbyMap.
  ///
  /// In zh, this message translates to:
  /// **'地图选店'**
  String get nearbyMap;

  /// No description provided for @wantedList.
  ///
  /// In zh, this message translates to:
  /// **'想去清单'**
  String get wantedList;

  /// No description provided for @preferenceTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的口味偏好'**
  String get preferenceTitle;

  /// No description provided for @preferenceTags.
  ///
  /// In zh, this message translates to:
  /// **'偏好标签'**
  String get preferenceTags;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @cookModeTitle.
  ///
  /// In zh, this message translates to:
  /// **'烹饪模式'**
  String get cookModeTitle;

  /// No description provided for @generateRecipe.
  ///
  /// In zh, this message translates to:
  /// **'生成菜谱'**
  String get generateRecipe;

  /// No description provided for @login.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get login;

  /// No description provided for @register.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码？'**
  String get forgotPassword;

  /// No description provided for @themeClassicDesc.
  ///
  /// In zh, this message translates to:
  /// **'明亮轻快，适合日常选餐'**
  String get themeClassicDesc;

  /// No description provided for @themeGhoulDesc.
  ///
  /// In zh, this message translates to:
  /// **'暗色高对比，灵感来自东京喰种'**
  String get themeGhoulDesc;

  /// No description provided for @themeStyle.
  ///
  /// In zh, this message translates to:
  /// **'主题风格'**
  String get themeStyle;

  /// No description provided for @themeMode.
  ///
  /// In zh, this message translates to:
  /// **'明暗模式'**
  String get themeMode;

  /// No description provided for @ghoulModeFixed.
  ///
  /// In zh, this message translates to:
  /// **'喰种暗红主题为固定暗色风格'**
  String get ghoulModeFixed;

  /// No description provided for @appearanceLocalOnly.
  ///
  /// In zh, this message translates to:
  /// **'外观设置仅在当前设备生效'**
  String get appearanceLocalOnly;

  /// No description provided for @nearbySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'探店用：看看你周边有什么好吃的'**
  String get nearbySubtitle;

  /// No description provided for @searchRestaurantHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索商圈、餐厅或菜系'**
  String get searchRestaurantHint;

  /// No description provided for @mapNoLocation.
  ///
  /// In zh, this message translates to:
  /// **'暂无定位，已按默认区域展示'**
  String get mapNoLocation;

  /// No description provided for @mapNoRestaurants.
  ///
  /// In zh, this message translates to:
  /// **'附近暂无可展示的餐厅坐标'**
  String get mapNoRestaurants;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
