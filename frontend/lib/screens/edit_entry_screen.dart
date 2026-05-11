import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';
import '../theme/app_text_styles.dart';
import 'entry_form_body.dart';

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
    _savings          = TextEditingController(text: _fmt(e.savingsCollected));
    _internalPrincipal= TextEditingController(text: _fmt(e.internalLoanPrincipalDisbursed));
    _internalInterest = TextEditingController(text: _fmt(e.internalLoanInterestCollected));
    _toBank           = TextEditingController(text: _fmt(e.toBank));
    _fromBank         = TextEditingController(text: _fmt(e.fromBank));
    _sofaDisbursed    = TextEditingController(text: _fmt(e.sofaLoanDisbursed));
    _sofaRepayment    = TextEditingController(text: _fmt(e.sofaLoanRepayment));
    _sofaInterest     = TextEditingController(text: _fmt(e.sofaLoanInterestCollected));
    _notes            = TextEditingController(text: e.notes ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _savings, _internalPrincipal, _internalInterest,
      _toBank, _fromBank, _sofaDisbursed, _sofaRepayment, _sofaInterest, _notes,
    ]) { c.dispose(); }
    super.dispose();
  }

  String _fmt(double v) {
    if (v == 0) return '';
    final n = v.round();
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

  double _val(TextEditingController c) {
    final raw = c.text.replaceAll(RegExp(r'[₹,\s]'), '');
    return double.tryParse(raw) ?? 0;
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() { _saving = true; _saveError = null; });
    try {
      final updated = widget.entry.copyWith(
        savingsCollected:              _val(_savings),
        internalLoanPrincipalDisbursed: _val(_internalPrincipal),
        internalLoanInterestCollected:  _val(_internalInterest),
        toBank:                        _val(_toBank),
        fromBank:                      _val(_fromBank),
        sofaLoanDisbursed:             _val(_sofaDisbursed),
        sofaLoanRepayment:             _val(_sofaRepayment),
        sofaLoanInterestCollected:     _val(_sofaInterest),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      await ref.read(entriesProvider.notifier).updateEntry(updated);
      if (mounted) context.pop();
    } catch (_) {
      setState(() { _saveError = AppLocalizations.of(context).errorFailedToSave; });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final groupsState = ref.watch(groupsProvider);
    final group = groupsState.maybeWhen(
      data: (gs) => gs.where((g) => g.id == widget.entry.groupId).firstOrNull,
      orElse: () => null,
    );
    final groupName = group?.name ?? '${l10n.groupLedger} ${widget.entry.groupId}';
    final month = DateFormat('MMMM yyyy').format(DateTime.parse(widget.entry.entryMonth));

    // Compute prior values: Σ all entries before this month for this group
    final allEntries = ref.watch(entriesProvider).maybeWhen(
      data: (list) => list,
      orElse: () => <MonthEntry>[],
    );
    final prior = allEntries.where((e) =>
        e.groupId == widget.entry.groupId &&
        e.entryMonth.compareTo(widget.entry.entryMonth) < 0).toList();

    final priorSavings    = prior.fold(0.0, (s, e) => s + e.savingsCollected);
    final priorPrincipal  = prior.fold(0.0, (s, e) => s + e.internalLoanPrincipalDisbursed);
    final priorInterest   = prior.fold(0.0, (s, e) => s + e.internalLoanInterestCollected);
    final priorToBank     = prior.fold(0.0, (s, e) => s + e.toBank);
    final priorFromBank   = prior.fold(0.0, (s, e) => s + e.fromBank);
    final priorSofaDis    = prior.fold(0.0, (s, e) => s + e.sofaLoanDisbursed);
    final priorSofaRep    = prior.fold(0.0, (s, e) => s + e.sofaLoanRepayment);
    final priorSofaInt    = prior.fold(0.0, (s, e) => s + e.sofaLoanInterestCollected);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(groupName, style: AppTextStyles.appBarTitle),
            Text(month,     style: AppTextStyles.appBarSubtitle),
          ],
        ),
      ),
      body: SafeArea(
        child: EntryFormBody(
          savings:           _savings,
          internalPrincipal: _internalPrincipal,
          internalInterest:  _internalInterest,
          toBank:            _toBank,
          fromBank:          _fromBank,
          sofaDisbursed:     _sofaDisbursed,
          sofaRepayment:     _sofaRepayment,
          sofaInterest:      _sofaInterest,
          notes:             _notes,
          priorSavings:    priorSavings,
          priorPrincipal:  priorPrincipal,
          priorInterest:   priorInterest,
          openingBankBalance: group?.openingBankBalance ?? 0,
          priorToBank:     priorToBank,
          priorFromBank:   priorFromBank,
          priorSofaDisbursed: priorSofaDis,
          priorSofaRepayment: priorSofaRep,
          priorSofaInterest:  priorSofaInt,
          saving:    _saving,
          saveError: _saveError,
          saveLabel: l10n.saveChanges,
          onSave:    () => _save(l10n),
        ),
      ),
    );
  }
}
