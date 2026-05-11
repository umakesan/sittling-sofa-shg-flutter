import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ta'),
    Locale('ta', 'IN')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SHG Portal'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sittilingi · SOFA'**
  String get appSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @enterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please enter your user ID and password.'**
  String get enterCredentials;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @contactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Contact your admin if you need access.'**
  String get contactAdmin;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @dashboardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTooltip;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync data'**
  String get syncData;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get statusSynced;

  /// No description provided for @statusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get statusSaved;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusSavedWithWarnings.
  ///
  /// In en, this message translates to:
  /// **'Saved with warnings'**
  String get statusSavedWithWarnings;

  /// No description provided for @pendingSyncCount.
  ///
  /// In en, this message translates to:
  /// **'Pending sync ({count})'**
  String pendingSyncCount(int count);

  /// No description provided for @recentEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent entries'**
  String get recentEntries;

  /// No description provided for @noSyncedEntries.
  ///
  /// In en, this message translates to:
  /// **'No synced entries yet.'**
  String get noSyncedEntries;

  /// No description provided for @couldNotLoadEntries.
  ///
  /// In en, this message translates to:
  /// **'Could not load entries.'**
  String get couldNotLoadEntries;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @allSynced.
  ///
  /// In en, this message translates to:
  /// **'All synced'**
  String get allSynced;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} entry pending} other{{count} entries pending}}'**
  String pendingCount(int count);

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time} ago'**
  String lastSynced(String time);

  /// No description provided for @newEntryStepTitle.
  ///
  /// In en, this message translates to:
  /// **'New Entry — Step {step} of 2'**
  String newEntryStepTitle(int step);

  /// No description provided for @selectGroupAndMonth.
  ///
  /// In en, this message translates to:
  /// **'Select group and month'**
  String get selectGroupAndMonth;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get selectMonth;

  /// No description provided for @couldNotLoadGroups.
  ///
  /// In en, this message translates to:
  /// **'Could not load groups. Please check your connection and try again.'**
  String get couldNotLoadGroups;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @reviewMonthlyTotals.
  ///
  /// In en, this message translates to:
  /// **'Review monthly totals'**
  String get reviewMonthlyTotals;

  /// No description provided for @editMonthlyTotals.
  ///
  /// In en, this message translates to:
  /// **'Edit monthly totals'**
  String get editMonthlyTotals;

  /// No description provided for @savingsSection.
  ///
  /// In en, this message translates to:
  /// **'SAVINGS'**
  String get savingsSection;

  /// No description provided for @bankCashSection.
  ///
  /// In en, this message translates to:
  /// **'BANK / CASH'**
  String get bankCashSection;

  /// No description provided for @sofaLoanSection.
  ///
  /// In en, this message translates to:
  /// **'SOFA LOAN'**
  String get sofaLoanSection;

  /// No description provided for @savingsCollected.
  ///
  /// In en, this message translates to:
  /// **'Savings Collected'**
  String get savingsCollected;

  /// No description provided for @intLoanPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Int. Loan Principal'**
  String get intLoanPrincipal;

  /// No description provided for @overallInterest.
  ///
  /// In en, this message translates to:
  /// **'Overall Interest'**
  String get overallInterest;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @toBank.
  ///
  /// In en, this message translates to:
  /// **'To Bank'**
  String get toBank;

  /// No description provided for @fromBank.
  ///
  /// In en, this message translates to:
  /// **'From Bank'**
  String get fromBank;

  /// No description provided for @loanDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Loan Disbursed'**
  String get loanDisbursed;

  /// No description provided for @loanReturn.
  ///
  /// In en, this message translates to:
  /// **'Loan Return'**
  String get loanReturn;

  /// No description provided for @interest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interest;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveEntry.
  ///
  /// In en, this message translates to:
  /// **'Save entry'**
  String get saveEntry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @groupLedger.
  ///
  /// In en, this message translates to:
  /// **'Group Ledger'**
  String get groupLedger;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @intLoan.
  ///
  /// In en, this message translates to:
  /// **'Int. Loan'**
  String get intLoan;

  /// No description provided for @sofaLoan.
  ///
  /// In en, this message translates to:
  /// **'SOFA Loan'**
  String get sofaLoan;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @noGroupEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries for this group yet.'**
  String get noGroupEntriesYet;

  /// No description provided for @villageWideTotals.
  ///
  /// In en, this message translates to:
  /// **'Village-wide totals'**
  String get villageWideTotals;

  /// No description provided for @basedOnEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Based on {count} entry stored on this device} other{Based on {count} entries stored on this device}}'**
  String basedOnEntries(int count);

  /// No description provided for @totalSavingsCollected.
  ///
  /// In en, this message translates to:
  /// **'Total savings collected'**
  String get totalSavingsCollected;

  /// No description provided for @internalLoanPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Internal loan principal'**
  String get internalLoanPrincipal;

  /// No description provided for @internalLoanInterest.
  ///
  /// In en, this message translates to:
  /// **'Internal loan interest'**
  String get internalLoanInterest;

  /// No description provided for @sofaLoansDisbursed.
  ///
  /// In en, this message translates to:
  /// **'SOFA loans disbursed'**
  String get sofaLoansDisbursed;

  /// No description provided for @sofaLoansRepaid.
  ///
  /// In en, this message translates to:
  /// **'SOFA loans repaid'**
  String get sofaLoansRepaid;

  /// No description provided for @warningEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} entry has warnings} other{{count} entries have warnings}}'**
  String warningEntriesCount(int count);

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @allEntriesUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All entries up to date'**
  String get allEntriesUpToDate;

  /// No description provided for @adminSection.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get adminSection;

  /// No description provided for @newVillage.
  ///
  /// In en, this message translates to:
  /// **'New village'**
  String get newVillage;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @syncNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please connect and try again.'**
  String get syncNoInternet;

  /// No description provided for @syncSuccessCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} entry uploaded successfully.} other{{count} entries uploaded successfully.}}'**
  String syncSuccessCount(int count);

  /// No description provided for @syncFailedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} entry could not be uploaded.} other{{count} entries could not be uploaded.}}'**
  String syncFailedCount(int count);

  /// No description provided for @nothingToSync.
  ///
  /// In en, this message translates to:
  /// **'Nothing to sync — all up to date.'**
  String get nothingToSync;

  /// No description provided for @syncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Sync (up to date)'**
  String get syncUpToDate;

  /// No description provided for @syncPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync ({count} pending)'**
  String syncPendingLabel(int count);

  /// No description provided for @errorFailedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get errorFailedToSave;

  /// No description provided for @warningToBankExceedsCollections.
  ///
  /// In en, this message translates to:
  /// **'To bank exceeds visible collections. Check the figures.'**
  String get warningToBankExceedsCollections;

  /// No description provided for @warningBankWithdrawalNoDeposit.
  ///
  /// In en, this message translates to:
  /// **'Bank withdrawal present with no deposit this month.'**
  String get warningBankWithdrawalNoDeposit;

  /// No description provided for @warningsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} warning} other{{count} warnings}}'**
  String warningsCount(int count);

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langTamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get langTamil;

  /// No description provided for @langMixed.
  ///
  /// In en, this message translates to:
  /// **'த/En'**
  String get langMixed;

  /// No description provided for @metricTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get metricTotal;

  /// No description provided for @metricThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get metricThisMonth;

  /// No description provided for @thisMonthSavings.
  ///
  /// In en, this message translates to:
  /// **'This month\'s savings'**
  String get thisMonthSavings;

  /// No description provided for @sectionToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get sectionToday;

  /// No description provided for @sectionRestOfMonth.
  ///
  /// In en, this message translates to:
  /// **'REST OF MONTH'**
  String get sectionRestOfMonth;

  /// No description provided for @notYetCollected.
  ///
  /// In en, this message translates to:
  /// **'Not yet collected'**
  String get notYetCollected;

  /// No description provided for @searchGroupsHint.
  ///
  /// In en, this message translates to:
  /// **'Search groups…'**
  String get searchGroupsHint;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'Meeting date'**
  String get sortByDate;

  /// No description provided for @sortByGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get sortByGroupName;

  /// No description provided for @sortByVillage.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get sortByVillage;

  /// No description provided for @noGroupsFound.
  ///
  /// In en, this message translates to:
  /// **'No groups found'**
  String get noGroupsFound;

  /// No description provided for @stripOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get stripOpening;

  /// No description provided for @stripAfterSave.
  ///
  /// In en, this message translates to:
  /// **'After save'**
  String get stripAfterSave;
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
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'ta':
      {
        switch (locale.countryCode) {
          case 'IN':
            return AppLocalizationsTaIn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
