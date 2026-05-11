import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sofa_loan.dart';
import '../models/sofa_loan_entry.dart';
import 'shared_providers.dart';

final sofaLoansProvider = FutureProvider.family<List<SofaLoan>, int>((ref, groupId) async {
  return ref.read(apiClientProvider).fetchSofaLoans(groupId);
});

final activeSofaLoanProvider = Provider.family<SofaLoan?, int>((ref, groupId) {
  return ref.watch(sofaLoansProvider(groupId)).maybeWhen(
        data: (loans) {
          try {
            return loans.firstWhere((l) => l.isActive);
          } catch (_) {
            return null;
          }
        },
        orElse: () => null,
      );
});

final sofaLoanEntriesProvider =
    FutureProvider.family<List<SofaLoanEntry>, int>((ref, loanId) async {
  return ref.read(apiClientProvider).fetchSofaLoanEntries(loanId);
});
