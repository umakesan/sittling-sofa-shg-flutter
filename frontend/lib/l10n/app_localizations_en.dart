// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SHG Portal';

  @override
  String get appSubtitle => 'Sittilingi · SOFA';

  @override
  String get signIn => 'Sign in';

  @override
  String get userId => 'User ID';

  @override
  String get password => 'Password';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get enterCredentials => 'Please enter your user ID and password.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get contactAdmin => 'Contact your admin if you need access.';

  @override
  String get home => 'Home';

  @override
  String get newEntry => 'New Entry';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get dashboardTooltip => 'Dashboard';

  @override
  String get ledger => 'Ledger';

  @override
  String get syncData => 'Sync data';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusSynced => 'Synced';

  @override
  String get statusSaved => 'Saved';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSavedWithWarnings => 'Saved with warnings';

  @override
  String pendingSyncCount(int count) {
    return 'Pending sync ($count)';
  }

  @override
  String get recentEntries => 'Recent entries';

  @override
  String get noSyncedEntries => 'No synced entries yet.';

  @override
  String get couldNotLoadEntries => 'Could not load entries.';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get allSynced => 'All synced';

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries pending',
      one: '$count entry pending',
    );
    return '$_temp0';
  }

  @override
  String lastSynced(String time) {
    return 'Last synced $time ago';
  }

  @override
  String newEntryStepTitle(int step) {
    return 'New Entry — Step $step of 2';
  }

  @override
  String get selectGroupAndMonth => 'Select group and month';

  @override
  String get selectMonth => 'Select month';

  @override
  String get couldNotLoadGroups =>
      'Could not load groups. Please check your connection and try again.';

  @override
  String get continueButton => 'Continue';

  @override
  String get reviewMonthlyTotals => 'Review monthly totals';

  @override
  String get editMonthlyTotals => 'Edit monthly totals';

  @override
  String get savingsSection => 'SAVINGS';

  @override
  String get bankCashSection => 'BANK / CASH';

  @override
  String get sofaLoanSection => 'SOFA LOAN';

  @override
  String get savingsCollected => 'Savings Collected';

  @override
  String get intLoanPrincipal => 'Int. Loan Principal';

  @override
  String get overallInterest => 'Overall Interest';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get toBank => 'To Bank';

  @override
  String get fromBank => 'From Bank';

  @override
  String get loanDisbursed => 'Loan Disbursed';

  @override
  String get loanReturn => 'Loan Return';

  @override
  String get interest => 'Interest';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving…';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveEntry => 'Save entry';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get groupLedger => 'Group Ledger';

  @override
  String get month => 'Month';

  @override
  String get savings => 'Savings';

  @override
  String get intLoan => 'Int. Loan';

  @override
  String get sofaLoan => 'SOFA Loan';

  @override
  String get status => 'Status';

  @override
  String get noGroupEntriesYet => 'No entries for this group yet.';

  @override
  String get villageWideTotals => 'Village-wide totals';

  @override
  String basedOnEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Based on $count entries stored on this device',
      one: 'Based on $count entry stored on this device',
    );
    return '$_temp0';
  }

  @override
  String get totalSavingsCollected => 'Total savings collected';

  @override
  String get internalLoanPrincipal => 'Internal loan principal';

  @override
  String get internalLoanInterest => 'Internal loan interest';

  @override
  String get sofaLoansDisbursed => 'SOFA loans disbursed';

  @override
  String get sofaLoansRepaid => 'SOFA loans repaid';

  @override
  String warningEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries have warnings',
      one: '$count entry has warnings',
    );
    return '$_temp0';
  }

  @override
  String get syncing => 'Syncing…';

  @override
  String get allEntriesUpToDate => 'All entries up to date';

  @override
  String get adminSection => 'ADMIN';

  @override
  String get newVillage => 'New village';

  @override
  String get newGroup => 'New group';

  @override
  String get syncNoInternet =>
      'No internet connection. Please connect and try again.';

  @override
  String syncSuccessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries uploaded successfully.',
      one: '$count entry uploaded successfully.',
    );
    return '$_temp0';
  }

  @override
  String syncFailedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries could not be uploaded.',
      one: '$count entry could not be uploaded.',
    );
    return '$_temp0';
  }

  @override
  String get nothingToSync => 'Nothing to sync — all up to date.';

  @override
  String get syncUpToDate => 'Sync (up to date)';

  @override
  String syncPendingLabel(int count) {
    return 'Sync ($count pending)';
  }

  @override
  String get errorFailedToSave => 'Failed to save. Please try again.';

  @override
  String get warningToBankExceedsCollections =>
      'To bank exceeds visible collections. Check the figures.';

  @override
  String get warningBankWithdrawalNoDeposit =>
      'Bank withdrawal present with no deposit this month.';

  @override
  String warningsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count warnings',
      one: '$count warning',
    );
    return '$_temp0';
  }

  @override
  String get langEnglish => 'English';

  @override
  String get langTamil => 'தமிழ்';

  @override
  String get langMixed => 'த/En';

  @override
  String get metricTotal => 'Total';

  @override
  String get metricThisMonth => 'This month';
}
