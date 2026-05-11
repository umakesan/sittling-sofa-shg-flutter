import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

// ── Section accent palette ──────────────────────────────────────────────────
const _kGreenAccent = Color(0xFF15803D);
const _kGreenHeader = Color(0xFFF0FDF4);
const _kGreenHeaderBorder = Color(0xFFD1FAE5);
const _kGreenSubrow = Color(0xFFF9FAFB);
const _kGreenSubtotal = Color(0xFFDCFCE7);

const _kBlueAccent = Color(0xFF1D4ED8);
const _kBlueHeader = Color(0xFFEFF6FF);
const _kBlueHeaderBorder = Color(0xFFBFDBFE);
const _kBlueSubrow = Color(0xFFFAFBFF);
const _kBlueSubtotal = Color(0xFFEFF6FF);

const _kAmberAccent = Color(0xFFB45309);
const _kAmberHeader = Color(0xFFFFFBEB);
const _kAmberHeaderBorder = Color(0xFFFDE68A);
const _kAmberSubrow = Color(0xFFFEFCE8);
const _kAmberSubtotal = Color(0xFFFFFBEB);
const _kAmberInterestBg = Color(0xFFFFFBEB);

const _kSeparator = Color(0xFFCBD5E1);
const _kRowBorder = Color(0xFFF1F5F9);

// ── Indian number formatter (2-2-3 grouping) ────────────────────────────────
String _inr(double value) {
  final n = value.round();
  final neg = n < 0;
  var s = n.abs().toString();
  if (s.length <= 3) return '₹ ${neg ? '-' : ''}$s';
  final last3 = s.substring(s.length - 3);
  s = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (s.length > 2) {
    parts.insert(0, s.substring(s.length - 2));
    s = s.substring(0, s.length - 2);
  }
  if (s.isNotEmpty) parts.insert(0, s);
  return '₹ ${neg ? '-' : ''}${parts.join(',')},$last3';
}

double _val(TextEditingController c) {
  final raw = c.text.replaceAll(RegExp(r'[₹,\s]'), '');
  return double.tryParse(raw) ?? 0;
}

// Formats an integer as Indian-grouped string for use in TextFields ("₹ 9,88,290").
String _fmtINR(int n) {
  var s = n.toString();
  if (s.length <= 3) return '₹ $s';
  final last3 = s.substring(s.length - 3);
  s = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (s.length > 2) {
    parts.insert(0, s.substring(s.length - 2));
    s = s.substring(0, s.length - 2);
  }
  if (s.isNotEmpty) parts.insert(0, s);
  return '₹ ${parts.join(',')},$last3';
}

class _IndianNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final n = int.parse(digits);
    final formatted = _fmtINR(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ── Main form widget ─────────────────────────────────────────────────────────

/// Shared ledger entry form used by both NewEntryScreen (step 2) and
/// EditEntryScreen. Computes all derived values live as the user types.
class EntryFormBody extends StatelessWidget {
  // ── Input controllers (8 financial + notes) ────────────────────────────
  final TextEditingController savings;
  final TextEditingController internalPrincipal;
  final TextEditingController internalInterest;
  final TextEditingController toBank;
  final TextEditingController fromBank;
  final TextEditingController sofaDisbursed;
  final TextEditingController sofaRepayment;
  final TextEditingController sofaInterest;
  final TextEditingController notes;

  // ── Prior values (Σ all months before this one for this group) ─────────
  final double priorSavings;
  final double priorPrincipal;
  final double priorInterest;
  final double openingBankBalance; // group-level constant, never changes
  final double priorToBank;
  final double priorFromBank;
  final double priorSofaDisbursed;
  final double priorSofaRepayment;
  final double priorSofaInterest;

  // ── Save state ──────────────────────────────────────────────────────────
  final bool saving;
  final String? saveError;
  final String saveLabel;
  final VoidCallback onSave;

  const EntryFormBody({
    super.key,
    required this.savings,
    required this.internalPrincipal,
    required this.internalInterest,
    required this.toBank,
    required this.fromBank,
    required this.sofaDisbursed,
    required this.sofaRepayment,
    required this.sofaInterest,
    required this.notes,
    required this.priorSavings,
    required this.priorPrincipal,
    required this.priorInterest,
    required this.openingBankBalance,
    required this.priorToBank,
    required this.priorFromBank,
    required this.priorSofaDisbursed,
    required this.priorSofaRepayment,
    required this.priorSofaInterest,
    required this.saving,
    this.saveError,
    required this.saveLabel,
    required this.onSave,
  });

  Listenable get _financialListenable => Listenable.merge([
        savings,
        internalPrincipal,
        internalInterest,
        toBank,
        fromBank,
        sofaDisbursed,
        sofaRepayment,
        sofaInterest,
      ]);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _financialListenable,
      builder: (context, _) {
        // ── Step 1–9 computation ───────────────────────────────────────────
        final inSav  = _val(savings);
        final inPrin = _val(internalPrincipal);
        final inInt  = _val(internalInterest);
        final inDep  = _val(toBank);
        final inWith = _val(fromBank);
        final inDis  = _val(sofaDisbursed);
        final inRep  = _val(sofaRepayment);
        final inSint = _val(sofaInterest);

        final clSav  = priorSavings   + inSav;   // step 1
        final clPrin = priorPrincipal + inPrin;  // step 2
        final clInt  = priorInterest  + inInt;   // step 3
        final collection = inSav + inPrin + inInt; // step 4

        final totalToBank   = priorToBank   + inDep;  // step 5
        final totalFromBank = priorFromBank + inWith; // step 6
        final closingBank = openingBankBalance + totalToBank - totalFromBank; // step 7

        final totalDisbursed = priorSofaDisbursed + inDis; // step 8
        final totalRepaid    = priorSofaRepayment + inRep;
        final sofaBalance    = totalDisbursed - totalRepaid;
        final totalSofaInt   = priorSofaInterest + inSint;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── SAVINGS & INTERNAL LOANS ─────────────────────────────
              _SectionCard(
                accentColor: _kGreenAccent,
                headerBg: _kGreenHeader,
                headerBorder: _kGreenHeaderBorder,
                icon: Icons.savings_outlined,
                title: l10n.savingsSection,
                children: [
                  _LedgerSectionHeader(prefix: '+', prefixColor: _kGreenAccent, title: l10n.savingsCollected),
                  _LedgerSubrow(label: l10n.priorMonths, value: _inr(priorSavings), bg: _kGreenSubrow),
                  _LedgerInputRow(label: l10n.metricThisMonth, controller: savings, accentColor: _kGreenAccent),
                  _LedgerSubtotal(label: l10n.totalSavingsCollected, value: _inr(clSav), bg: _kGreenSubtotal, textColor: _kGreenAccent),
                  _LedgerSectionHeader(prefix: '+', prefixColor: _kGreenAccent, title: l10n.intLoanPrincipal),
                  _LedgerSubrow(label: l10n.priorMonths, value: _inr(priorPrincipal), bg: _kGreenSubrow),
                  _LedgerInputRow(label: l10n.metricThisMonth, controller: internalPrincipal, accentColor: _kGreenAccent),
                  _LedgerSubtotal(label: l10n.internalLoanPrincipal, value: _inr(clPrin), bg: _kGreenSubtotal, textColor: _kGreenAccent),
                  _LedgerSectionHeader(prefix: '+', prefixColor: _kGreenAccent, title: l10n.overallInterest),
                  _LedgerSubrow(label: l10n.priorMonths, value: _inr(priorInterest), bg: _kGreenSubrow),
                  _LedgerInputRow(label: l10n.metricThisMonth, controller: internalInterest, accentColor: _kGreenAccent, isLast: true),
                  _LedgerSubtotal(label: l10n.internalLoanInterest, value: _inr(clInt), bg: _kGreenSubtotal, textColor: _kGreenAccent, hasBottomBorder: false),
                  const _LedgerSeparator(),
                  _CollectionBanner(amount: collection, label: l10n.collectionThisMonth),
                ],
              ),
              const SizedBox(height: 11),

              // ── BANK ─────────────────────────────────────────────────
              _SectionCard(
                accentColor: _kBlueAccent,
                headerBg: _kBlueHeader,
                headerBorder: _kBlueHeaderBorder,
                icon: Icons.account_balance_outlined,
                title: l10n.bankCashSection,
                children: [
                  _LedgerStaticRow(
                    prefix: '=',
                    prefixColor: const Color(0xFF94A3B8),
                    label: l10n.openingBalanceInitial,
                    labelSuffix: l10n.initialTag,
                    value: _inr(openingBankBalance),
                  ),
                  _LedgerSectionHeader(
                    prefix: '+',
                    prefixColor: _kGreenAccent,
                    title: l10n.toBank,
                  ),
                  _LedgerSubrow(
                    label: l10n.priorMonths,
                    value: _inr(priorToBank),
                    bg: _kBlueSubrow,
                  ),
                  _LedgerInputRow(
                    label: l10n.metricThisMonth,
                    controller: toBank,
                    accentColor: _kBlueAccent,
                  ),
                  _LedgerSubtotal(
                    label: l10n.totalToBank,
                    value: _inr(totalToBank),
                    bg: _kBlueSubtotal,
                    textColor: _kBlueAccent,
                  ),
                  _LedgerSectionHeader(
                    prefix: '−',
                    prefixColor: AppColors.error,
                    title: l10n.fromBank,
                  ),
                  _LedgerSubrow(
                    label: l10n.priorMonths,
                    value: _inr(priorFromBank),
                    bg: _kBlueSubrow,
                  ),
                  _LedgerInputRow(
                    label: l10n.metricThisMonth,
                    controller: fromBank,
                    accentColor: _kBlueAccent,
                    isLast: true,
                  ),
                  _LedgerSubtotal(
                    label: l10n.totalFromBank,
                    value: _inr(totalFromBank),
                    bg: _kBlueSubtotal,
                    textColor: _kBlueAccent,
                    hasBottomBorder: false,
                  ),
                  const _LedgerSeparator(),
                  _LedgerClosing(
                    label: l10n.closingBalance,
                    value: _inr(closingBank),
                    valueColor: closingBank < 0 ? AppColors.error : _kBlueAccent,
                  ),
                ],
              ),
              const SizedBox(height: 11),

              // ── SOFA LOAN ─────────────────────────────────────────────
              _SectionCard(
                accentColor: _kAmberAccent,
                headerBg: _kAmberHeader,
                headerBorder: _kAmberHeaderBorder,
                icon: Icons.agriculture_outlined,
                title: l10n.sofaLoanSection,
                children: [
                  _LedgerSectionHeader(
                    prefix: '+',
                    prefixColor: _kGreenAccent,
                    title: l10n.sofaDisbursedSection,
                  ),
                  _LedgerSubrow(
                    label: l10n.priorMonths,
                    value: _inr(priorSofaDisbursed),
                    bg: _kAmberSubrow,
                  ),
                  _LedgerInputRow(
                    label: l10n.metricThisMonth,
                    controller: sofaDisbursed,
                    accentColor: _kAmberAccent,
                  ),
                  _LedgerSubtotal(
                    label: l10n.totalDisbursed,
                    value: _inr(totalDisbursed),
                    bg: _kAmberSubtotal,
                    textColor: _kAmberAccent,
                  ),
                  _LedgerSectionHeader(
                    prefix: '−',
                    prefixColor: AppColors.error,
                    title: l10n.loanRepaidSection,
                  ),
                  _LedgerSubrow(
                    label: l10n.priorMonths,
                    value: _inr(priorSofaRepayment),
                    bg: _kAmberSubrow,
                  ),
                  _LedgerInputRow(
                    label: l10n.metricThisMonth,
                    controller: sofaRepayment,
                    accentColor: _kAmberAccent,
                    isLast: true,
                  ),
                  _LedgerSubtotal(
                    label: l10n.totalRepaid,
                    value: _inr(totalRepaid),
                    bg: _kAmberSubtotal,
                    textColor: _kAmberAccent,
                    hasBottomBorder: false,
                  ),
                  const _LedgerSeparator(),
                  _LedgerClosing(
                    label: l10n.loanBalance,
                    value: _inr(sofaBalance),
                    valueColor: sofaBalance < 0
                        ? AppColors.error
                        : sofaBalance == 0
                            ? _kGreenAccent
                            : _kAmberAccent,
                  ),
                  // Interest sub-section (income only)
                  Container(
                    height: 1,
                    color: _kAmberHeaderBorder,
                    margin: const EdgeInsets.symmetric(horizontal: 13),
                  ),
                  _InterestHeader(
                    title: l10n.interestCollected,
                    note: l10n.interestIncomeNote,
                    bg: _kAmberInterestBg,
                  ),
                  _LedgerSubrow(
                    label: l10n.priorMonths,
                    value: _inr(priorSofaInterest),
                    bg: _kAmberSubrow,
                  ),
                  _LedgerInputRow(
                    label: l10n.metricThisMonth,
                    controller: sofaInterest,
                    accentColor: _kAmberAccent,
                  ),
                  _LedgerSubtotal(
                    label: l10n.totalInterest,
                    value: _inr(totalSofaInt),
                    bg: _kAmberSubtotal,
                    textColor: _kAmberAccent,
                    hasBottomBorder: false,
                  ),
                ],
              ),
              const SizedBox(height: 11),

              // ── NOTES ────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(13, 4, 13, 8),
                child: TextField(
                  controller: notes,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).notesOptional,
                    border: InputBorder.none,
                    labelStyle: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                      height: 1.55,
                    ),
                  ),
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── SAVE ERROR ───────────────────────────────────────────
              if (saveError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    saveError!,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors.error,
                      height: 1.55,
                    ),
                  ),
                ),

              // ── SAVE BUTTON ──────────────────────────────────────────
              FilledButton(
                onPressed: saving ? null : onSave,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  saving ? AppLocalizations.of(context).saving : saveLabel,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Private composable widgets
// ════════════════════════════════════════════════════════════════════════════

/// Card with a 4px colored left accent bar and a tinted header row.
class _SectionCard extends StatelessWidget {
  final Color accentColor;
  final Color headerBg;
  final Color headerBorder;
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.accentColor,
    required this.headerBg,
    required this.headerBorder,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accentColor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    color: headerBg,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                    child: Row(
                      children: [
                        Icon(icon, size: 14, color: accentColor),
                        const SizedBox(width: 6),
                        Text(
                          title,
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: accentColor,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: headerBorder),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Highlighted "Collection this month" banner at the bottom of the savings card.
class _CollectionBanner extends StatelessWidget {
  final double amount;
  final String label;
  const _CollectionBanner({required this.amount, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
        ),
        border: Border(top: BorderSide(color: Color(0xFF86EFAC), width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: _kGreenAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF166534),
                height: 1.3,
              ),
            ),
          ),
          Text(
            _inr(amount),
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF14532D),
              fontFeatures: [const FontFeature.tabularFigures()],
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Static display row: [prefix] label (suffix tag)   ₹ value.
class _LedgerStaticRow extends StatelessWidget {
  final String prefix;
  final Color prefixColor;
  final String label;
  final String? labelSuffix;
  final String value;

  const _LedgerStaticRow({
    required this.prefix,
    required this.prefixColor,
    required this.label,
    this.labelSuffix,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kRowBorder)),
      ),
      child: Row(
        children: [
          _PrefixSymbol(symbol: prefix, color: prefixColor),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: label,
                style: GoogleFonts.notoSans(
                    fontSize: 12.5, color: const Color(0xFF374151), height: 1.35),
                children: labelSuffix == null
                    ? []
                    : [
                        TextSpan(
                          text: ' $labelSuffix',
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            color: const Color(0xFF94A3B8),
                            height: 1.35,
                          ),
                        )
                      ],
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 13.5,
              color: const Color(0xFF64748B),
              fontFeatures: [const FontFeature.tabularFigures()],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bold section header row with +/− prefix: e.g. "+ To Bank".
class _LedgerSectionHeader extends StatelessWidget {
  final String prefix;
  final Color prefixColor;
  final String title;

  const _LedgerSectionHeader({
    required this.prefix,
    required this.prefixColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 5),
      child: Row(
        children: [
          _PrefixSymbol(symbol: prefix, color: prefixColor, large: true),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indented muted row showing prior-months cumulative value.
class _LedgerSubrow extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;

  const _LedgerSubrow({
    required this.label,
    required this.value,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(39, 6, 13, 6),
      color: bg,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                  fontSize: 11, color: const Color(0xFF94A3B8), height: 1.3),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
              fontFeatures: [const FontFeature.tabularFigures()],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indented input row with a styled TextField inside a pill container.
class _LedgerInputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color accentColor;
  final bool isLast;

  const _LedgerInputRow({
    required this.label,
    required this.controller,
    required this.accentColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(39, 6, 13, 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : const BorderSide(color: _kRowBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                  fontSize: 11.5, color: const Color(0xFF64748B), height: 1.3),
            ),
          ),
          _FieldPill(controller: controller, accentColor: accentColor),
        ],
      ),
    );
  }
}

/// Colored subtotal row: "Total To Bank   ₹ 9,88,290".
class _LedgerSubtotal extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color textColor;
  final bool hasBottomBorder;

  const _LedgerSubtotal({
    required this.label,
    required this.value,
    required this.bg,
    required this.textColor,
    this.hasBottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(39, 7, 13, 7),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: hasBottomBorder
              ? BorderSide(color: textColor.withOpacity(0.15))
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
              fontFeatures: [const FontFeature.tabularFigures()],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin horizontal separator line before the closing row.
class _LedgerSeparator extends StatelessWidget {
  const _LedgerSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: _kSeparator,
      margin: const EdgeInsets.symmetric(horizontal: 13),
    );
  }
}

/// Bold closing row with large amount: "= Closing Balance   ₹ 22,281".
class _LedgerClosing extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _LedgerClosing({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
      child: Row(
        children: [
          _PrefixSymbol(symbol: '=', color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
                height: 1.3,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor,
              fontFeatures: [const FontFeature.tabularFigures()],
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header for the SOFA interest sub-section (income-only row).
class _InterestHeader extends StatelessWidget {
  final String title;
  final String note;
  final Color bg;

  const _InterestHeader({
    required this.title,
    required this.note,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 12.5,
              color: const Color(0xFF92400E),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            note,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              color: const Color(0xFFD97706),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Leaf input widgets ───────────────────────────────────────────────────────

/// Pill-shaped input used in all ledger input rows (savings, bank, SOFA).
/// Displays formatted Indian currency (₹ 9,88,290) right-aligned; dash hint when empty.
class _FieldPill extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;

  const _FieldPill({required this.controller, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    );
    return SizedBox(
      width: 135,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.right,
        inputFormatters: [_IndianNumberFormatter()],
        style: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
          fontFeatures: [const FontFeature.tabularFigures()],
          height: 1.2,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(8, 7, 12, 7),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          hintText: '—',
          hintStyle: GoogleFonts.notoSans(
            fontSize: 16,
            color: const Color(0xFFCBD5E1),
            height: 1.0,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Small +/−/= prefix symbol.
class _PrefixSymbol extends StatelessWidget {
  final String symbol;
  final Color color;
  final bool large;

  const _PrefixSymbol({
    required this.symbol,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      child: Text(
        symbol,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: large ? 15 : 14,
          fontWeight: FontWeight.w800,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }
}
