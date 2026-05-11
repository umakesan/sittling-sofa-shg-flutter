import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shg_portal/l10n/app_localizations.dart';

import '../models/sofa_loan.dart';
import '../models/sofa_loan_entry.dart';
import '../providers/sofa_loans_provider.dart';
import '../providers/shared_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

final _fmt = NumberFormat('#,##0');
final _dateFmt = DateFormat('d MMM yyyy');

class GroupSofaLoanScreen extends ConsumerStatefulWidget {
  final int groupId;

  const GroupSofaLoanScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupSofaLoanScreen> createState() => _GroupSofaLoanScreenState();
}

class _GroupSofaLoanScreenState extends ConsumerState<GroupSofaLoanScreen> {
  bool _closing = false;
  String? _error;

  Future<void> _closeLoan(int loanId, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.sofaCloseConfirmTitle),
        content: Text(l10n.sofaCloseConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.sofaCloseLoan),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() { _closing = true; _error = null; });
    try {
      await ref.read(apiClientProvider).closeSofaLoan(loanId);
      ref.invalidate(sofaLoansProvider(widget.groupId));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loansAsync = ref.watch(sofaLoansProvider(widget.groupId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sofaLoansScreenTitle)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: loansAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(e.toString(),
                    style: AppTextStyles.body.copyWith(color: AppColors.error)),
              ),
              data: (loans) {
                final active = loans.where((l) => l.isActive).firstOrNull;
                final past = loans.where((l) => !l.isActive).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!,
                            style: AppTextStyles.body.copyWith(color: AppColors.error)),
                      ),

                    // Active loan card
                    if (active != null) ...[
                      _SectionHeader(l10n.sofaActiveLoan),
                      _ActiveLoanCard(
                        loan: active,
                        closing: _closing,
                        onClose: () => _closeLoan(active.id, l10n),
                        l10n: l10n,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // New loan button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(l10n.sofaNewLoan),
                      onPressed: active != null
                          ? null
                          : () => _showCreateSheet(l10n),
                    ),

                    // Past loans
                    if (past.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(l10n.sofaPastLoans),
                      ...past.map((loan) => _PastLoanTile(loan: loan, l10n: l10n)),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateSheet(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CreateLoanSheet(
        groupId: widget.groupId,
        onCreated: () {
          ref.invalidate(sofaLoansProvider(widget.groupId));
          Navigator.pop(ctx);
        },
        l10n: l10n,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ActiveLoanCard extends StatelessWidget {
  final SofaLoan loan;
  final bool closing;
  final VoidCallback onClose;
  final AppLocalizations l10n;

  const _ActiveLoanCard({
    required this.loan,
    required this.closing,
    required this.onClose,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final disbursedDate =
        DateTime.tryParse(loan.disbursedDate) != null
            ? _dateFmt.format(DateTime.parse(loan.disbursedDate))
            : loan.disbursedDate;
    final totalRepaid = loan.principalAmount - loan.outstanding;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: l10n.sofaPrincipal,
                value: '₹ ${_fmt.format(loan.principalAmount)}'),
            _InfoRow(label: l10n.sofaDisbursedDate, value: disbursedDate),
            _InfoRow(label: l10n.sofaTotalRepaid,
                value: '₹ ${_fmt.format(totalRepaid)}'),
            _InfoRow(
              label: l10n.sofaOutstanding,
              value: '₹ ${_fmt.format(loan.outstanding)}',
              valueColor: loan.outstanding > 0
                  ? AppColors.warning
                  : AppColors.synced,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: (loan.outstanding > 0 || closing) ? null : onClose,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppColors.error,
              ),
              child: Text(closing ? '…' : l10n.sofaCloseLoan),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(
            value,
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PastLoanTile extends ConsumerWidget {
  final SofaLoan loan;
  final AppLocalizations l10n;

  const _PastLoanTile({required this.loan, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disbursedDate =
        DateTime.tryParse(loan.disbursedDate) != null
            ? _dateFmt.format(DateTime.parse(loan.disbursedDate))
            : loan.disbursedDate;

    return ExpansionTile(
      title: Text('₹ ${_fmt.format(loan.principalAmount)}',
          style: AppTextStyles.title),
      subtitle: Text(disbursedDate, style: AppTextStyles.label),
      children: [
        _LoanEntriesTable(loanId: loan.id, l10n: l10n),
      ],
    );
  }
}

class _LoanEntriesTable extends ConsumerWidget {
  final int loanId;
  final AppLocalizations l10n;

  const _LoanEntriesTable({required this.loanId, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(sofaLoanEntriesProvider(loanId));
    return entriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(e.toString(),
            style: AppTextStyles.body.copyWith(color: AppColors.error)),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const SizedBox.shrink();
        }
        return Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
          },
          children: [
            _tableHeader(),
            ...entries.map(_tableRow),
          ],
        );
      },
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.surfaceVariant),
      children: ['Month', 'Disbursed', 'Repaid', 'Interest']
          .map((h) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(h,
                    style: AppTextStyles.label
                        .copyWith(fontWeight: FontWeight.w600)),
              ))
          .toList(),
    );
  }

  TableRow _tableRow(SofaLoanEntry e) {
    final month = DateTime.tryParse(e.entryMonth) != null
        ? DateFormat('MMM yy').format(DateTime.parse(e.entryMonth))
        : e.entryMonth;
    return TableRow(children: [
      _cell(month),
      _cell(e.disbursed > 0 ? '₹ ${_fmt.format(e.disbursed)}' : '—'),
      _cell(e.repayment > 0 ? '₹ ${_fmt.format(e.repayment)}' : '—'),
      _cell(e.interestCollected > 0 ? '₹ ${_fmt.format(e.interestCollected)}' : '—'),
    ]);
  }

  Widget _cell(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(text, style: AppTextStyles.label),
      );
}

// ---------------------------------------------------------------------------

class _CreateLoanSheet extends ConsumerStatefulWidget {
  final int groupId;
  final VoidCallback onCreated;
  final AppLocalizations l10n;

  const _CreateLoanSheet({
    required this.groupId,
    required this.onCreated,
    required this.l10n,
  });

  @override
  ConsumerState<_CreateLoanSheet> createState() => _CreateLoanSheetState();
}

class _CreateLoanSheetState extends ConsumerState<_CreateLoanSheet> {
  final _principalCtrl = TextEditingController();
  DateTime _disbursedDate = DateTime.now();
  bool _creating = false;
  String? _error;

  @override
  void dispose() {
    _principalCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final principal = double.tryParse(_principalCtrl.text.trim());
    if (principal == null || principal <= 0) {
      setState(() => _error = 'Enter a valid principal amount');
      return;
    }
    setState(() { _creating = true; _error = null; });
    try {
      await ref.read(apiClientProvider).createSofaLoan(
        widget.groupId,
        principal,
        DateFormat('yyyy-MM-dd').format(_disbursedDate),
      );
      widget.onCreated();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.sofaCreateLoanTitle, style: AppTextStyles.headline),
          const SizedBox(height: 20),
          TextField(
            controller: _principalCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.sofaPrincipalHint,
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              '${l10n.sofaDisbursedDate}: ${_dateFmt.format(_disbursedDate)}',
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _disbursedDate,
                firstDate: DateTime(2010),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _disbursedDate = picked);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _creating ? null : _create,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: Text(_creating ? '…' : l10n.sofaCreateButton),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 12),
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
