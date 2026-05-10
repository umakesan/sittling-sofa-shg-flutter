import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/month_entry.dart';
import '../providers/entries_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (entries) {
          final summary = _summarise(entries);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Village-wide totals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Based on ${entries.length} entries stored on this device',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              _StatCard(
                  label: 'Total savings collected',
                  value: summary.totalSavingsCollected),
              _StatCard(
                  label: 'Internal loan principal',
                  value: summary.totalInternalLoanPrincipal),
              _StatCard(
                  label: 'Internal loan interest',
                  value: summary.totalInternalLoanInterest),
              _StatCard(
                  label: 'SOFA loans disbursed',
                  value: summary.totalSofaDisbursed),
              _StatCard(
                  label: 'SOFA loans repaid',
                  value: summary.totalSofaRepaid),
              if (summary.warningEntryCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Text(
                    '${summary.warningEntryCount} entries have warnings',
                    style: const TextStyle(color: Color(0xFF92400E)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  _DashboardSummary _summarise(List<MonthEntry> entries) {
    double savings = 0, principal = 0, interest = 0, sofa = 0, sofaRepaid = 0;
    int warnings = 0;
    for (final e in entries) {
      savings += e.savingsCollected;
      principal += e.internalLoanPrincipalDisbursed;
      interest += e.internalLoanInterestCollected;
      sofa += e.sofaLoanDisbursed;
      sofaRepaid += e.sofaLoanRepayment;
      if (e.warningFlags.isNotEmpty) warnings++;
    }
    return _DashboardSummary(
      totalSavingsCollected: savings,
      totalInternalLoanPrincipal: principal,
      totalInternalLoanInterest: interest,
      totalSofaDisbursed: sofa,
      totalSofaRepaid: sofaRepaid,
      warningEntryCount: warnings,
    );
  }
}

class _DashboardSummary {
  final double totalSavingsCollected;
  final double totalInternalLoanPrincipal;
  final double totalInternalLoanInterest;
  final double totalSofaDisbursed;
  final double totalSofaRepaid;
  final int warningEntryCount;

  const _DashboardSummary({
    required this.totalSavingsCollected,
    required this.totalInternalLoanPrincipal,
    required this.totalInternalLoanInterest,
    required this.totalSofaDisbursed,
    required this.totalSofaRepaid,
    required this.warningEntryCount,
  });
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: Text(formatted,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
