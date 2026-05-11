// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'SHG போர்டல்';

  @override
  String get appSubtitle => 'சித்திலிங்கி · SOFA';

  @override
  String get signIn => 'உள்நுழைக';

  @override
  String get userId => 'பயனர் ID';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get signingIn => 'உள்நுழைகிறது…';

  @override
  String get enterCredentials =>
      'உங்கள் பயனர் ID மற்றும் கடவுச்சொல்லை உள்ளிடவும்.';

  @override
  String get somethingWentWrong =>
      'ஏதோ தவறாகிவிட்டது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get contactAdmin =>
      'அணுகல் தேவைப்பட்டால் உங்கள் நிர்வாகியை தொடர்பு கொள்ளவும்.';

  @override
  String get home => 'முகப்பு';

  @override
  String get newEntry => 'புதிய பதிவு';

  @override
  String get dashboard => 'தரவகம்';

  @override
  String get dashboardTooltip => 'தரவகம்';

  @override
  String get ledger => 'கணக்கு ஏடு';

  @override
  String get syncData => 'தரவை ஒத்திசை';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get language => 'மொழி';

  @override
  String get statusPending => 'நிலுவையில்';

  @override
  String get statusSynced => 'ஒத்திசைக்கப்பட்டது';

  @override
  String get statusSaved => 'சேமிக்கப்பட்டது';

  @override
  String get statusDraft => 'வரைவு';

  @override
  String get statusSavedWithWarnings => 'எச்சரிக்கைகளுடன் சேமிக்கப்பட்டது';

  @override
  String pendingSyncCount(int count) {
    return 'நிலுவையில் உள்ளவை ($count)';
  }

  @override
  String get recentEntries => 'சமீபத்திய பதிவுகள்';

  @override
  String get noSyncedEntries => 'இன்னும் ஒத்திசைக்கப்பட்ட பதிவுகள் இல்லை.';

  @override
  String get couldNotLoadEntries => 'பதிவுகளை ஏற்ற முடியவில்லை.';

  @override
  String get offline => 'இணைப்பு இல்லை';

  @override
  String get online => 'இணைப்பு உள்ளது';

  @override
  String get allSynced => 'அனைத்தும் ஒத்திசைக்கப்பட்டது';

  @override
  String pendingCount(int count) {
    return '$count பதிவுகள் நிலுவையில்';
  }

  @override
  String lastSynced(String time) {
    return '$time முன்பு ஒத்திசைக்கப்பட்டது';
  }

  @override
  String newEntryStepTitle(int step) {
    return 'புதிய பதிவு — படி $step இல் 2';
  }

  @override
  String get selectGroupAndMonth => 'குழு மற்றும் மாதத்தை தேர்ந்தெடுக்கவும்';

  @override
  String get selectMonth => 'மாதத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get couldNotLoadGroups =>
      'குழுக்களை ஏற்ற முடியவில்லை. உங்கள் இணைப்பை சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get continueButton => 'தொடர்க';

  @override
  String get reviewMonthlyTotals => 'மாத மொத்தங்களை சரிபார்க்கவும்';

  @override
  String get editMonthlyTotals => 'மாத மொத்தங்களை திருத்தவும்';

  @override
  String get savingsSection => 'சேமிப்பு';

  @override
  String get bankCashSection => 'வங்கி / பணம்';

  @override
  String get sofaLoanSection => 'SOFA கடன்';

  @override
  String get savingsCollected => 'சேகரிக்கப்பட்ட சேமிப்பு';

  @override
  String get intLoanPrincipal => 'உள் கடன் அசல்';

  @override
  String get overallInterest => 'மொத்த வட்டி';

  @override
  String get totalAmount => 'மொத்த தொகை';

  @override
  String get toBank => 'வங்கிக்கு';

  @override
  String get fromBank => 'வங்கியிலிருந்து';

  @override
  String get loanDisbursed => 'வழங்கிய கடன்';

  @override
  String get loanReturn => 'கடன் திரும்ப';

  @override
  String get interest => 'வட்டி';

  @override
  String get notesOptional => 'குறிப்புகள் (விரும்பினால்)';

  @override
  String get save => 'சேமி';

  @override
  String get saving => 'சேமிக்கிறது…';

  @override
  String get saveChanges => 'மாற்றங்களை சேமி';

  @override
  String get saveEntry => 'பதிவை சேமி';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get back => 'திரும்பு';

  @override
  String get groupLedger => 'குழு கணக்கு ஏடு';

  @override
  String get month => 'மாதம்';

  @override
  String get savings => 'சேமிப்பு';

  @override
  String get intLoan => 'உள் கடன்';

  @override
  String get sofaLoan => 'SOFA கடன்';

  @override
  String get status => 'நிலை';

  @override
  String get noGroupEntriesYet => 'இந்த குழுவிற்கு இன்னும் பதிவுகள் இல்லை.';

  @override
  String get villageWideTotals => 'கிராம மொத்த கணக்கு';

  @override
  String basedOnEntries(int count) {
    return 'இந்த சாதனத்தில் $count பதிவுகள் உள்ளன';
  }

  @override
  String get totalSavingsCollected => 'மொத்த சேகரிக்கப்பட்ட சேமிப்பு';

  @override
  String get internalLoanPrincipal => 'மொத்த உள் கடன் அசல்';

  @override
  String get internalLoanInterest => 'மொத்த உள் கடன் வட்டி';

  @override
  String get sofaLoansDisbursed => 'வழங்கிய SOFA கடன்கள்';

  @override
  String get sofaLoansRepaid => 'திரும்பப்பெற்ற SOFA கடன்கள்';

  @override
  String warningEntriesCount(int count) {
    return '$count பதிவுகளில் எச்சரிக்கைகள் உள்ளன';
  }

  @override
  String get syncing => 'ஒத்திசைக்கிறது…';

  @override
  String get allEntriesUpToDate => 'அனைத்து பதிவுகளும் புதுப்பித்தலாகும்';

  @override
  String get adminSection => 'நிர்வாகி';

  @override
  String get newVillage => 'புதிய கிராமம்';

  @override
  String get newGroup => 'புதிய குழு';

  @override
  String get syncNoInternet =>
      'இணைய இணைப்பு இல்லை. இணைத்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String syncSuccessCount(int count) {
    return '$count பதிவுகள் வெற்றிகரமாக பதிவேற்றப்பட்டன.';
  }

  @override
  String syncFailedCount(int count) {
    return '$count பதிவுகளை பதிவேற்ற முடியவில்லை.';
  }

  @override
  String get nothingToSync =>
      'ஒத்திசைக்க எதுவும் இல்லை — அனைத்தும் புதுப்பித்தலாகும்.';

  @override
  String get syncUpToDate => 'ஒத்திசைவு (புதுப்பித்தலாகும்)';

  @override
  String syncPendingLabel(int count) {
    return 'ஒத்திசைவு ($count நிலுவையில்)';
  }

  @override
  String get errorFailedToSave => 'சேமிக்க தவறியது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get warningToBankExceedsCollections =>
      'வங்கிக்கு செலுத்திய தொகை சேகரிப்பை மீறுகிறது. தொகைகளை சரிபார்க்கவும்.';

  @override
  String get warningBankWithdrawalNoDeposit =>
      'இந்த மாதம் வைப்பு இல்லாமல் வங்கி திரும்பப்பெறுதல் உள்ளது.';

  @override
  String warningsCount(int count) {
    return '$count எச்சரிக்கைகள்';
  }

  @override
  String get langEnglish => 'English';

  @override
  String get langTamil => 'தமிழ்';

  @override
  String get langMixed => 'த/En';

  @override
  String get metricTotal => 'மொத்தம்';

  @override
  String get metricThisMonth => 'இந்த மாதம்';

  @override
  String get savingsOverview => 'சேமிப்பு கணக்கு';

  @override
  String get totalSavingsAsset => 'மொத்த சேமிப்பு சொத்து';

  @override
  String get savingsCorpus => 'சேமிப்பு நிதி';

  @override
  String get interestEarned => 'வட்டி வருமானம்';

  @override
  String villagesCount(int count) {
    return '$count கிராமங்கள்';
  }

  @override
  String groupsCount(int count) {
    return '$count குழுக்கள்';
  }

  @override
  String get monthlyLedger => 'மாதாந்திர கணக்கு';

  @override
  String get noEntriesYet => 'இன்னும் பதிவுகள் இல்லை.';

  @override
  String lastEntryMonth(String month) {
    return 'கடைசி: $month';
  }

  @override
  String get sortBy => 'வரிசையிடு';

  @override
  String get sortHighestFirst => 'அதிக முதல்';

  @override
  String get sortByName => 'பெயர் வரிசை';

  @override
  String get cumulative => 'ஒட்டுமொத்தம்';

  @override
  String get reportsSection => 'அறிக்கைகள்';

  @override
  String get internalLoansReport => 'உள் கடன்கள்';

  @override
  String get bankTransactionsReport => 'வங்கி பரிவர்த்தனைகள்';

  @override
  String get groupActivityReport => 'குழு செயல்பாடு';

  @override
  String get comingSoon => 'விரைவில் வரும்';

  @override
  String get sofaLoansReport => 'SOFA கடன்கள்';

  @override
  String get bankFlowReport => 'வங்கி பாய்வு';

  @override
  String get villageCompareReport => 'கிராம ஒப்பீடு';

  @override
  String get overdueAlertsReport => 'தாமதமான எச்சரிக்கைகள்';

  @override
  String get trendsReport => 'போக்குகள்';

  @override
  String get groupHealthReport => 'குழு ஆரோக்கியம்';

  @override
  String get recoveryRateReport => 'மீட்பு விகிதம்';

  @override
  String get auditLogReport => 'தணிக்கை பதிவு';

  @override
  String get outstanding => 'நிலுவை';

  @override
  String get recoveryRate => 'மீட்பு %';

  @override
  String get netFlow => 'நிகர பாய்வு';

  @override
  String get deposited => 'வைப்பு';

  @override
  String get withdrawn => 'எடுப்பு';

  @override
  String get noAlerts => 'அனைத்து குழுக்களும் சரியாக உள்ளன';

  @override
  String get regularity => 'ஒழுங்குமுறை';

  @override
  String get missingMonths => 'காணாத மாதங்கள்';

  @override
  String get corpusGrowth => 'நிதி வளர்ச்சி';

  @override
  String get monthlyContributions => 'மாதாந்திர பங்களிப்புகள்';

  @override
  String get thisMonthSavings => 'இந்த மாத சேமிப்பு';

  @override
  String get sectionToday => 'இன்று';

  @override
  String get sectionRestOfMonth => 'மாதத்தின் மீதி';

  @override
  String get notYetCollected => 'இன்னும் சேகரிக்கப்படவில்லை';

  @override
  String get searchGroupsHint => 'குழுக்களை தேடவும்…';

  @override
  String get sortTooltip => 'வரிசைப்படுத்து';

  @override
  String get sortByDate => 'கூட்ட தேதி';

  @override
  String get sortByGroupName => 'குழு பெயர்';

  @override
  String get sortByVillage => 'கிராமம்';

  @override
  String get noGroupsFound => 'குழுக்கள் கிடைக்கவில்லை';

  @override
  String get stripOpening => 'தொடக்கம்';

  @override
  String get stripAfterSave => 'சேமிப்புக்கு பின்';

  @override
  String get sofaLoansScreenTitle => 'SOFA கடன்கள்';

  @override
  String get sofaActiveLoan => 'செயலில் உள்ள கடன்';

  @override
  String get sofaNewLoan => 'புதிய கடன்';

  @override
  String get sofaPastLoans => 'கடந்த கடன்கள்';

  @override
  String get sofaPrincipal => 'அசல்';

  @override
  String get sofaDisbursedDate => 'வழங்கிய தேதி';

  @override
  String get sofaTotalRepaid => 'மொத்த திரும்பப் பெறப்பட்டது';

  @override
  String get sofaOutstanding => 'நிலுவை';

  @override
  String get sofaCloseLoan => 'கடனை மூடு';

  @override
  String get sofaCloseConfirmTitle => 'இந்த கடனை மூட வேண்டுமா?';

  @override
  String get sofaCloseConfirmBody =>
      'கடனை முழுமையாக திரும்பப் பெறப்பட்டதாக குறிக்கவும். இதை மாற்ற முடியாது.';

  @override
  String get sofaCreateLoanTitle => 'புதிய கடன் உருவாக்கு';

  @override
  String get sofaPrincipalHint => 'அசல் தொகை (₹)';

  @override
  String get sofaCreateButton => 'கடன் உருவாக்கு';

  @override
  String get sofaNoActiveLoanHint =>
      'இந்த குழுவிற்கு செயலில் உள்ள SOFA கடன் இல்லை.';

  @override
  String sofaActiveLoanChip(String outstanding) {
    return 'செயலில் உள்ள கடன் — ₹$outstanding நிலுவை';
  }

  @override
  String get ledgerColOpening => 'தொடக்கம்';

  @override
  String get ledgerColThisMonth => 'இந்த மாதம்';

  @override
  String get ledgerColClosing => 'இறுதி';

  @override
  String get collectionThisMonth => 'இந்த மாத வசூல்';

  @override
  String get openingBalanceInitial => 'ஆரம்ப இருப்பு';

  @override
  String get initialTag => '(ஆரம்பம்)';

  @override
  String get priorMonths => 'முந்தைய மாதங்கள்';

  @override
  String get totalToBank => 'மொத்த வங்கி வரவு';

  @override
  String get totalFromBank => 'மொத்த வங்கி செலவு';

  @override
  String get closingBalance => 'இறுதி இருப்பு';

  @override
  String get sofaDisbursedSection => 'SOFA கடன் வழங்கல்';

  @override
  String get loanRepaidSection => 'கடன் திரும்ப செலுத்தல்';

  @override
  String get totalDisbursed => 'மொத்த வழங்கல்';

  @override
  String get totalRepaid => 'மொத்த திரும்ப செலுத்தல்';

  @override
  String get loanBalance => 'கடன் இருப்பு';

  @override
  String get interestCollected => 'வட்டி வசூல்';

  @override
  String get interestIncomeNote =>
      'கூட்டமைப்பிற்கு வருமானம் — கடன் இருப்பை பாதிக்காது';

  @override
  String get totalInterest => 'மொத்த வட்டி';

  @override
  String get warnBankNegative =>
      'வங்கி இருப்பு எதிர்மறையாக உள்ளது — வரவு மற்றும் செலவை சரிபார்க்கவும்.';

  @override
  String get warnSofaNegative =>
      'SOFA கடன் இருப்பு எதிர்மறையாக உள்ளது — திரும்ப செலுத்தல் அதிகமாக உள்ளது.';
}

/// The translations for Tamil, as used in India (`ta_IN`).
class AppLocalizationsTaIn extends AppLocalizationsTa {
  AppLocalizationsTaIn() : super('ta_IN');

  @override
  String get appTitle => 'SHG Portal';

  @override
  String get appSubtitle => 'சித்திலிங்கி · SOFA';

  @override
  String get signIn => 'Sign in செய்யவும்';

  @override
  String get userId => 'User ID';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get signingIn => 'உள்நுழைகிறது…';

  @override
  String get enterCredentials =>
      'உங்கள் User ID மற்றும் கடவுச்சொல்லை உள்ளிடவும்.';

  @override
  String get somethingWentWrong => 'ஏதோ தவறாகிவிட்டது. மீண்டும் try செய்யவும்.';

  @override
  String get contactAdmin => 'அணுகல் தேவைப்பட்டால் Admin-ஐ தொடர்பு கொள்ளவும்.';

  @override
  String get home => 'முகப்பு';

  @override
  String get newEntry => 'புதிய பதிவு';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get dashboardTooltip => 'Dashboard';

  @override
  String get ledger => 'கணக்கு ஏடு';

  @override
  String get syncData => 'Sync செய்யவும்';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'மொழி';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusSynced => 'Synced';

  @override
  String get statusSaved => 'Saved';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSavedWithWarnings => 'Warnings உடன் Saved';

  @override
  String pendingSyncCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String get recentEntries => 'சமீபத்திய பதிவுகள்';

  @override
  String get noSyncedEntries => 'Synced பதிவுகள் இல்லை.';

  @override
  String get couldNotLoadEntries => 'பதிவுகளை load செய்ய முடியவில்லை.';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get allSynced => 'அனைத்தும் Synced';

  @override
  String pendingCount(int count) {
    return '$count entries pending';
  }

  @override
  String lastSynced(String time) {
    return 'Last sync: $time முன்பு';
  }

  @override
  String newEntryStepTitle(int step) {
    return 'புதிய பதிவு — Step $step of 2';
  }

  @override
  String get selectGroupAndMonth => 'குழு மற்றும் மாதத்தை தேர்ந்தெடுக்கவும்';

  @override
  String get selectMonth => 'மாதத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get couldNotLoadGroups =>
      'குழுக்களை load செய்ய முடியவில்லை. Connection சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get continueButton => 'தொடர்க';

  @override
  String get reviewMonthlyTotals => 'மாத Totals சரிபார்க்கவும்';

  @override
  String get editMonthlyTotals => 'மாத Totals திருத்தவும்';

  @override
  String get savingsSection => 'சேமிப்பு (Savings)';

  @override
  String get bankCashSection => 'வங்கி / Cash';

  @override
  String get sofaLoanSection => 'SOFA கடன்';

  @override
  String get savingsCollected => 'சேகரிக்கப்பட்ட சேமிப்பு';

  @override
  String get intLoanPrincipal => 'உள் கடன் Principal';

  @override
  String get overallInterest => 'மொத்த Interest';

  @override
  String get totalAmount => 'மொத்த தொகை';

  @override
  String get toBank => 'வங்கிக்கு';

  @override
  String get fromBank => 'வங்கியிலிருந்து';

  @override
  String get loanDisbursed => 'வழங்கிய Loan';

  @override
  String get loanReturn => 'Loan திரும்ப';

  @override
  String get interest => 'Interest';

  @override
  String get notesOptional => 'குறிப்புகள் (optional)';

  @override
  String get save => 'Save செய்யவும்';

  @override
  String get saving => 'Saving…';

  @override
  String get saveChanges => 'Changes சேமி';

  @override
  String get saveEntry => 'பதிவை Save செய்யவும்';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'திரும்பு';

  @override
  String get groupLedger => 'குழு Ledger';

  @override
  String get month => 'மாதம்';

  @override
  String get savings => 'சேமிப்பு';

  @override
  String get intLoan => 'உள் கடன்';

  @override
  String get sofaLoan => 'SOFA கடன்';

  @override
  String get status => 'நிலை';

  @override
  String get noGroupEntriesYet => 'இந்த குழுவிற்கு entries இல்லை.';

  @override
  String get villageWideTotals => 'கிராம மொத்த Totals';

  @override
  String basedOnEntries(int count) {
    return 'இந்த device-ல் $count entries உள்ளன';
  }

  @override
  String get totalSavingsCollected => 'மொத்த சேமிப்பு';

  @override
  String get internalLoanPrincipal => 'மொத்த Internal கடன் Principal';

  @override
  String get internalLoanInterest => 'மொத்த Internal கடன் Interest';

  @override
  String get sofaLoansDisbursed => 'வழங்கிய SOFA கடன்கள்';

  @override
  String get sofaLoansRepaid => 'திரும்பப்பெற்ற SOFA கடன்கள்';

  @override
  String warningEntriesCount(int count) {
    return '$count entries-ல் warnings உள்ளன';
  }

  @override
  String get syncing => 'Syncing…';

  @override
  String get allEntriesUpToDate => 'அனைத்து entries-ம் up to date';

  @override
  String get adminSection => 'ADMIN';

  @override
  String get newVillage => 'புதிய கிராமம்';

  @override
  String get newGroup => 'புதிய குழு';

  @override
  String get syncNoInternet =>
      'Internet இணைப்பு இல்லை. Connect ஆகி மீண்டும் முயற்சிக்கவும்.';

  @override
  String syncSuccessCount(int count) {
    return '$count entries வெற்றிகரமாக upload ஆனது.';
  }

  @override
  String syncFailedCount(int count) {
    return '$count entries upload ஆகவில்லை.';
  }

  @override
  String get nothingToSync =>
      'Sync செய்ய எதுவும் இல்லை — அனைத்தும் up to date.';

  @override
  String get syncUpToDate => 'Sync (up to date)';

  @override
  String syncPendingLabel(int count) {
    return 'Sync ($count pending)';
  }

  @override
  String get errorFailedToSave => 'Save ஆகவில்லை. மீண்டும் try செய்யவும்.';

  @override
  String get warningToBankExceedsCollections =>
      'வங்கிக்கு செலுத்திய தொகை சேகரிப்பை மீறுகிறது. தொகைகளை சரிபார்க்கவும்.';

  @override
  String get warningBankWithdrawalNoDeposit =>
      'இந்த மாதம் deposit இல்லாமல் bank withdrawal உள்ளது.';

  @override
  String warningsCount(int count) {
    return '$count warnings';
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

  @override
  String get savingsOverview => 'Savings Overview';

  @override
  String get totalSavingsAsset => 'Total Savings Asset';

  @override
  String get savingsCorpus => 'Savings Corpus';

  @override
  String get interestEarned => 'Interest வருமானம்';

  @override
  String get monthlyLedger => 'Monthly கணக்கு';

  @override
  String get noEntriesYet => 'இன்னும் entries இல்லை.';

  @override
  String get sortBy => 'Sort';

  @override
  String get cumulative => 'Cumulative';

  @override
  String get reportsSection => 'Reports';

  @override
  String get internalLoansReport => 'Internal Loans';

  @override
  String get bankTransactionsReport => 'Bank Transactions';

  @override
  String get groupActivityReport => 'Group Activity';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get sofaLoansReport => 'SOFA Loans';

  @override
  String get bankFlowReport => 'Bank Flow';

  @override
  String get villageCompareReport => 'Village Compare';

  @override
  String get overdueAlertsReport => 'Overdue Alerts';

  @override
  String get trendsReport => 'Trends';

  @override
  String get groupHealthReport => 'Group Health';

  @override
  String get recoveryRateReport => 'Recovery Rate';

  @override
  String get auditLogReport => 'Audit Log';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get recoveryRate => 'Recovery %';

  @override
  String get netFlow => 'Net Flow';

  @override
  String get deposited => 'Deposited';

  @override
  String get withdrawn => 'Withdrawn';

  @override
  String get noAlerts => 'All groups are up to date';

  @override
  String get regularity => 'Regularity';

  @override
  String get missingMonths => 'Missing months';

  @override
  String get corpusGrowth => 'Corpus Growth';

  @override
  String get monthlyContributions => 'Monthly Contributions';

  @override
  String get thisMonthSavings => 'இந்த மாத Savings';

  @override
  String get sectionToday => 'இன்று';

  @override
  String get sectionRestOfMonth => 'மாதத்தின் மீதி';

  @override
  String get notYetCollected => 'இன்னும் collect ஆகவில்லை';

  @override
  String get searchGroupsHint => 'குழுக்களை search செய்யவும்…';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortByDate => 'கூட்ட தேதி';

  @override
  String get sortByGroupName => 'குழு பெயர்';

  @override
  String get sortByVillage => 'கிராமம்';

  @override
  String get noGroupsFound => 'குழுக்கள் கிடைக்கவில்லை';

  @override
  String get stripOpening => 'தொடக்கம்';

  @override
  String get stripAfterSave => 'சேமிப்புக்கு பின்';

  @override
  String get ledgerColOpening => 'Opening';

  @override
  String get ledgerColThisMonth => 'This Month';

  @override
  String get ledgerColClosing => 'Closing';

  @override
  String get collectionThisMonth => 'இந்த மாத Collection';

  @override
  String get openingBalanceInitial => 'Opening Balance';

  @override
  String get initialTag => '(initial)';

  @override
  String get priorMonths => 'முந்தைய மாதங்கள்';

  @override
  String get totalToBank => 'Total To Bank';

  @override
  String get totalFromBank => 'Total From Bank';

  @override
  String get closingBalance => 'Closing Balance';

  @override
  String get sofaDisbursedSection => 'SOFA Disbursed';

  @override
  String get loanRepaidSection => 'Loan Repaid';

  @override
  String get totalDisbursed => 'Total Disbursed';

  @override
  String get totalRepaid => 'Total Repaid';

  @override
  String get loanBalance => 'Loan Balance';

  @override
  String get interestCollected => 'வட்டி வசூல்';

  @override
  String get interestIncomeNote =>
      'Federation-க்கு வருமானம் — கடன் இருப்பை பாதிக்காது';

  @override
  String get totalInterest => 'Total Interest';

  @override
  String get warnBankNegative =>
      'Bank balance negative — deposits மற்றும் withdrawals-ஐ சரிபார்க்கவும்.';

  @override
  String get warnSofaNegative =>
      'SOFA balance negative — repayment அதிகமாக உள்ளது.';
}
