import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';
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

  String _fmt(double v) => v == 0 ? '' : v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  double _val(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  List<String> get _warnings {
    final w = <String>[];
    final savings = _val(_savings);
    final interest = _val(_internalInterest);
    final toBank = _val(_toBank);
    final fromBank = _val(_fromBank);
    if (toBank > savings + interest + 1) {
      w.add('To bank exceeds visible collections. Check the figures.');
    }
    if (fromBank > 0 && toBank == 0) {
      w.add('Bank withdrawal present with no deposit this month.');
    }
    return w;
  }

  Future<void> _save() async {
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
      setState(() { _saveError = 'Failed to save. Please try again.'; });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupName = ref.watch(groupsProvider).maybeWhen(
      data: (groups) =>
          groups.where((g) => g.id == widget.entry.groupId).firstOrNull?.name,
      orElse: () => null,
    ) ?? 'Group ${widget.entry.groupId}';

    final month = DateFormat('MMMM yyyy')
        .format(DateTime.parse(widget.entry.entryMonth));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(groupName, style: const TextStyle(fontSize: 16)),
            Text(month, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit monthly totals',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _MoneyField(label: 'Savings collected (₹)', controller: _savings),
              _MoneyField(label: 'Internal loan principal disbursed (₹)', controller: _internalPrincipal),
              _MoneyField(label: 'Internal loan interest collected (₹)', controller: _internalInterest),
              _MoneyField(label: 'To bank (₹)', controller: _toBank),
              _MoneyField(label: 'From bank (₹)', controller: _fromBank),
              _MoneyField(label: 'SOFA loan disbursed (₹)', controller: _sofaDisbursed),
              _MoneyField(label: 'SOFA loan repayment (₹)', controller: _sofaRepayment),
              _MoneyField(label: 'SOFA loan interest collected (₹)', controller: _sofaInterest),
              TextField(
                controller: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: Listenable.merge([
                  _savings, _internalInterest, _toBank, _fromBank,
                ]),
                builder: (_, __) => WarningPanel(warnings: _warnings),
              ),
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_saveError!, style: const TextStyle(color: Colors.red)),
                ),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    minimumSize: const Size(double.infinity, 48)),
                child: Text(_saving ? 'Saving…' : 'Save changes'),
              ),
            ],
          ),
        ),
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
          border: const OutlineInputBorder(),
          prefixText: '₹ ',
        ),
      ),
    );
  }
}
