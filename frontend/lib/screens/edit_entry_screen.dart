import 'package:flutter/material.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/warning_panel.dart';

class EditEntryScreen extends ConsumerStatefulWidget {
  final MonthEntry entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  late final TextEditingController _savings;
  late final TextEditingController _internalPrincipal;
  late final TextEditingController _internalInterest;
  late final TextEditingController _toBank;
  late final TextEditingController _fromBank;
  late final TextEditingController _sofaDisbursed;
  late final TextEditingController _sofaRepayment;
  late final TextEditingController _sofaInterest;
  late final TextEditingController _notes;

  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _savings = TextEditingController(text: _fmt(e.savingsCollected));
    _internalPrincipal = TextEditingController(text: _fmt(e.internalLoanPrincipalDisbursed));
    _internalInterest = TextEditingController(text: _fmt(e.internalLoanInterestCollected));
    _toBank = TextEditingController(text: _fmt(e.toBank));
    _fromBank = TextEditingController(text: _fmt(e.fromBank));
    _sofaDisbursed = TextEditingController(text: _fmt(e.sofaLoanDisbursed));
    _sofaRepayment = TextEditingController(text: _fmt(e.sofaLoanRepayment));
    _sofaInterest = TextEditingController(text: _fmt(e.sofaLoanInterestCollected));
    _notes = TextEditingController(text: e.notes ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _savings, _internalPrincipal, _internalInterest,
      _toBank, _fromBank, _sofaDisbursed, _sofaRepayment,
      _sofaInterest, _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmt(double v) =>
      v == 0 ? '' : v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  double _val(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0;

  List<String> _getWarnings(AppLocalizations l10n) {
    final w = <String>[];
    final savings = _val(_savings);
    final interest = _val(_internalInterest);
    final toBank = _val(_toBank);
    final fromBank = _val(_fromBank);
    if (toBank > savings + interest + 1) {
      w.add(l10n.warningToBankExceedsCollections);
    }
    if (fromBank > 0 && toBank == 0) {
      w.add(l10n.warningBankWithdrawalNoDeposit);
    }
    return w;
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() { _saving = true; _saveError = null; });
    try {
      final updated = widget.entry.copyWith(
        savingsCollected: _val(_savings),
        internalLoanPrincipalDisbursed: _val(_internalPrincipal),
        internalLoanInterestCollected: _val(_internalInterest),
        toBank: _val(_toBank),
        fromBank: _val(_fromBank),
        sofaLoanDisbursed: _val(_sofaDisbursed),
        sofaLoanRepayment: _val(_sofaRepayment),
        sofaLoanInterestCollected: _val(_sofaInterest),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      await ref.read(entriesProvider.notifier).updateEntry(updated);
      if (mounted) context.pop();
    } catch (e) {
      setState(() { _saveError = l10n.errorFailedToSave; });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final groupName = ref.watch(groupsProvider).maybeWhen(
          data: (groups) => groups
              .where((g) => g.id == widget.entry.groupId)
              .firstOrNull
              ?.name,
          orElse: () => null,
        ) ??
        '${l10n.groupLedger} ${widget.entry.groupId}';

    final month =
        DateFormat('MMMM yyyy').format(DateTime.parse(widget.entry.entryMonth));

    final isTablet = MediaQuery.sizeOf(context).width >= 720;

    final totalRow = ListenableBuilder(
      listenable:
          Listenable.merge([_savings, _internalPrincipal, _internalInterest]),
      builder: (_, __) {
        final total = (double.tryParse(_savings.text.trim()) ?? 0) +
            (double.tryParse(_internalPrincipal.text.trim()) ?? 0) +
            (double.tryParse(_internalInterest.text.trim()) ?? 0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.totalAmount, style: AppTextStyles.title),
              Text('₹ ${NumberFormat('#,##0').format(total)}',
                  style: AppTextStyles.amount),
            ],
          ),
        );
      },
    );

    final warningPanel = ListenableBuilder(
      listenable: Listenable.merge(
          [_savings, _internalInterest, _toBank, _fromBank]),
      builder: (ctx, __) =>
          WarningPanel(warnings: _getWarnings(AppLocalizations.of(ctx))),
    );

    final leftFields = <Widget>[
      _SectionHeader(l10n.savingsSection),
      _MoneyField(label: l10n.savingsCollected, controller: _savings),
      _MoneyField(label: l10n.intLoanPrincipal, controller: _internalPrincipal),
      _MoneyField(label: l10n.overallInterest, controller: _internalInterest),
      totalRow,
      _SectionHeader(l10n.bankCashSection),
      _MoneyField(label: l10n.toBank, controller: _toBank),
      _MoneyField(label: l10n.fromBank, controller: _fromBank),
    ];

    final rightFields = <Widget>[
      _SectionHeader(l10n.sofaLoanSection),
      _MoneyField(label: l10n.loanDisbursed, controller: _sofaDisbursed),
      _MoneyField(label: l10n.loanReturn, controller: _sofaRepayment),
      _MoneyField(label: l10n.interest, controller: _sofaInterest),
      const SizedBox(height: 6),
      TextField(
        controller: _notes,
        decoration: InputDecoration(labelText: l10n.notesOptional),
        maxLines: 2,
      ),
      const SizedBox(height: 16),
      warningPanel,
      if (_saveError != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(_saveError!,
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
        ),
      FilledButton(
        onPressed: _saving ? null : () => _save(l10n),
        style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56)),
        child: Text(_saving ? l10n.saving : l10n.saveChanges),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(groupName, style: AppTextStyles.appBarTitle),
            Text(month, style: AppTextStyles.appBarSubtitle),
          ],
        ),
      ),
      body: SafeArea(
        child: isTablet
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.editMonthlyTotals,
                        style: AppTextStyles.headline),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: leftFields,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: rightFields,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.editMonthlyTotals,
                        style: AppTextStyles.headline),
                    const SizedBox(height: 20),
                    ...leftFields,
                    const SizedBox(height: 6),
                    ...rightFields,
                  ],
                ),
              ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.sectionHeader),
          const SizedBox(width: 10),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _MoneyField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
        ),
      ),
    );
  }
}
