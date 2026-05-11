import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'entry_form_body.dart';

class NewEntryScreen extends ConsumerStatefulWidget {
  const NewEntryScreen({super.key});

  @override
  ConsumerState<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends ConsumerState<NewEntryScreen> {
  int _step = 1;

  int? _groupId;
  DateTime? _month;

  final _savings           = TextEditingController();
  final _internalPrincipal = TextEditingController();
  final _internalInterest  = TextEditingController();
  final _toBank            = TextEditingController();
  final _fromBank          = TextEditingController();
  final _sofaDisbursed     = TextEditingController();
  final _sofaRepayment     = TextEditingController();
  final _sofaInterest      = TextEditingController();
  final _notes             = TextEditingController();

  bool _saving = false;
  String? _saveError;

  @override
  void dispose() {
    for (final c in [
      _savings, _internalPrincipal, _internalInterest,
      _toBank, _fromBank, _sofaDisbursed, _sofaRepayment, _sofaInterest, _notes,
    ]) { c.dispose(); }
    super.dispose();
  }

  double _val(TextEditingController c) {
    final raw = c.text.replaceAll(RegExp(r'[₹,\s]'), '');
    return double.tryParse(raw) ?? 0;
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() { _saving = true; _saveError = null; });
    try {
      await ref.read(entriesProvider.notifier).createEntry(
        groupId:                       _groupId!,
        entryMonth:                    DateFormat('yyyy-MM-01').format(_month!),
        entryMode:                     EntryMode.manual,
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
      if (mounted) context.go('/');
    } catch (_) {
      setState(() { _saveError = l10n.errorFailedToSave; });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Compute prior values when group + month are both selected
    final groupsAsync = ref.watch(groupsProvider);
    final group = (_groupId == null)
        ? null
        : groupsAsync.maybeWhen(
            data: (gs) => gs.where((g) => g.id == _groupId).firstOrNull,
            orElse: () => null,
          );

    final allEntries = ref.watch(entriesProvider).maybeWhen(
      data: (list) => list,
      orElse: () => <MonthEntry>[],
    );
    final entryMonthStr = _month == null
        ? null
        : DateFormat('yyyy-MM-01').format(_month!);
    final prior = (_groupId == null || entryMonthStr == null)
        ? <MonthEntry>[]
        : allEntries
            .where((e) =>
                e.groupId == _groupId &&
                e.entryMonth.compareTo(entryMonthStr) < 0)
            .toList();

    final priorSavings   = prior.fold(0.0, (s, e) => s + e.savingsCollected);
    final priorPrincipal = prior.fold(0.0, (s, e) => s + e.internalLoanPrincipalDisbursed);
    final priorInterest  = prior.fold(0.0, (s, e) => s + e.internalLoanInterestCollected);
    final priorToBank    = prior.fold(0.0, (s, e) => s + e.toBank);
    final priorFromBank  = prior.fold(0.0, (s, e) => s + e.fromBank);
    final priorSofaDis   = prior.fold(0.0, (s, e) => s + e.sofaLoanDisbursed);
    final priorSofaRep   = prior.fold(0.0, (s, e) => s + e.sofaLoanRepayment);
    final priorSofaInt   = prior.fold(0.0, (s, e) => s + e.sofaLoanInterestCollected);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newEntryStepTitle(_step)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step > 1) {
              setState(() => _step--);
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: switch (_step) {
              1 => _StepSelectGroup(
                  selectedGroupId: _groupId,
                  selectedMonth: _month,
                  onGroupSelected: (id) => setState(() => _groupId = id),
                  onMonthSelected: (m) => setState(() => _month = m),
                  onContinue: () => setState(() => _step = 2),
                ),
              _ => EntryFormBody(
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
                  saveLabel: l10n.saveEntry,
                  onSave:    () => _save(l10n),
                ),
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Select group and month (unchanged)
// ---------------------------------------------------------------------------

class _StepSelectGroup extends ConsumerWidget {
  final int? selectedGroupId;
  final DateTime? selectedMonth;
  final ValueChanged<int> onGroupSelected;
  final ValueChanged<DateTime> onMonthSelected;
  final VoidCallback onContinue;

  const _StepSelectGroup({
    required this.selectedGroupId,
    required this.selectedMonth,
    required this.onGroupSelected,
    required this.onMonthSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groupsAsync = ref.watch(groupsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(l10n.selectGroupAndMonth, style: AppTextStyles.headline),
        ),
        Expanded(
          child: groupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.couldNotLoadGroups,
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ),
            data: (groups) {
              final villageMap = <String, List<dynamic>>{};
              for (final g in groups) {
                villageMap.putIfAbsent(g.villageName, () => []).add(g);
              }
              final villages = villageMap.keys.toList()..sort();
              final selectedVillage = selectedGroupId == null
                  ? null
                  : groups
                      .firstWhere((g) => g.id == selectedGroupId,
                          orElse: () => groups.first)
                      .villageName;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: villages.length,
                itemBuilder: (context, i) {
                  final village = villages[i];
                  final villageGroups = villageMap[village]!;
                  return ExpansionTile(
                    key: PageStorageKey(village),
                    initiallyExpanded: village == selectedVillage,
                    leading: const Icon(Icons.location_on_outlined,
                        color: AppColors.primary),
                    title: Text(village, style: AppTextStyles.title),
                    trailing:
                        Text('${villageGroups.length}', style: AppTextStyles.label),
                    children: villageGroups.map<Widget>((g) {
                      final selected = g.id == selectedGroupId;
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        title: Text(g.name, style: AppTextStyles.body),
                        leading: Icon(
                          selected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                        tileColor:
                            selected ? AppColors.primaryContainer : null,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onTap: () => onGroupSelected(g.id),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text(selectedMonth == null
                    ? l10n.selectMonth
                    : DateFormat('MMMM yyyy').format(selectedMonth!)),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedMonth ?? now,
                    firstDate: DateTime(2020),
                    lastDate: now,
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                    helpText: l10n.selectMonth,
                  );
                  if (picked != null) {
                    onMonthSelected(DateTime(picked.year, picked.month));
                  }
                },
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: selectedGroupId != null && selectedMonth != null
                    ? onContinue
                    : null,
                child: Text(l10n.continueButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
