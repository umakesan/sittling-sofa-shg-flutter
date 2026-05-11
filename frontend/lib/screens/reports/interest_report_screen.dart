import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/interest_report_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/shimmer_loader.dart';

// ─── Formatters ───────────────────────────────────────────────────────────────

final _inrFmt =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

String _fmtMonth(String ym) {
  try {
    return DateFormat('MMM yyyy').format(DateTime.parse(ym)).toUpperCase();
  } catch (_) {
    return ym;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class InterestReportScreen extends ConsumerStatefulWidget {
  const InterestReportScreen({super.key});

  @override
  ConsumerState<InterestReportScreen> createState() =>
      _InterestReportScreenState();
}

class _InterestReportScreenState extends ConsumerState<InterestReportScreen> {
  String? _month;
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(interestReportProvider);

    return dataAsync.when(
      loading: () => Scaffold(
        appBar: _buildAppBar(l10n, null, null),
        body: _buildSkeleton(),
      ),
      error: (e, _) => Scaffold(
        appBar: _buildAppBar(l10n, null, null),
        body: Center(
            child: Text('$e',
                style: AppTextStyles.body.copyWith(color: AppColors.error))),
      ),
      data: (data) {
        if (data.months.isEmpty) {
          return Scaffold(
            appBar: _buildAppBar(l10n, null, null),
            body: Center(child: Text(l10n.noEntriesYet)),
          );
        }

        _month ??= data.months.last;
        final month = _month!;
        final idx = data.months.indexOf(month);
        final canPrev = idx > 0;
        final canNext = idx < data.months.length - 1;
        final monthData = data.byMonth[month]!;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(l10n, canPrev ? () {
            setState(() {
              _month = data.months[idx - 1];
              _expanded.clear();
            });
          } : null, canNext ? () {
            setState(() {
              _month = data.months[idx + 1];
              _expanded.clear();
            });
          } : null, monthLabel: _fmtMonth(month)),
          body: _buildBody(monthData, _fmtMonth(month)),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppLocalizations l10n,
    VoidCallback? onPrev,
    VoidCallback? onNext, {
    String? monthLabel,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 48),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3730A3), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Title row
              SizedBox(
                height: kToolbarHeight,
                child: Row(
                  children: [
                    const BackButton(color: Colors.white),
                    Expanded(
                      child: Text(l10n.interestEarned,
                          style: AppTextStyles.appBarTitle),
                    ),
                  ],
                ),
              ),
              // Month navigation row
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    _NavButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: onPrev,
                      tooltip: 'Previous month',
                    ),
                    Expanded(
                      child: Text(
                        monthLabel ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    _NavButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: onNext,
                      tooltip: 'Next month',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(InterestMonthData monthData, String fmtMonth) {
    return CustomScrollView(
      slivers: [
        // ── Hero summary ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _HeroSummary(
            total: monthData.totalInterest,
            monthLabel: fmtMonth,
          ),
        ),

        // ── Section header ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
            child: Text(
              'BY VILLAGE',
              style: AppTextStyles.sectionHeader,
            ),
          ),
        ),

        // ── Village list ─────────────────────────────────────────────────────
        if (monthData.villages.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No interest recorded this month.',
                    style: AppTextStyles.bodySecondary),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final village = monthData.villages[i];
                final isExpanded = _expanded.contains(village.villageName);
                return _VillageTile(
                  village: village,
                  isExpanded: isExpanded,
                  onToggle: () => setState(() => isExpanded
                      ? _expanded.remove(village.villageName)
                      : _expanded.add(village.villageName)),
                );
              },
              childCount: monthData.villages.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildSkeleton() => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ShimmerCard(height: 100, margin: EdgeInsets.only(bottom: 12)),
          ShimmerCard(height: 56, margin: EdgeInsets.only(bottom: 8)),
          ShimmerCard(height: 56, margin: EdgeInsets.only(bottom: 8)),
          ShimmerCard(height: 56, margin: EdgeInsets.only(bottom: 8)),
          ShimmerCard(height: 56),
        ],
      );
}

// ─── Nav button ───────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _NavButton(
      {required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: onTap != null ? Colors.white : Colors.white38,
      onPressed: onTap,
      tooltip: tooltip,
    );
  }
}

// ─── Hero summary ─────────────────────────────────────────────────────────────

class _HeroSummary extends StatelessWidget {
  final double total;
  final String monthLabel;

  const _HeroSummary({required this.total, required this.monthLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _inrFmt.format(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total interest · $monthLabel',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Village tile ─────────────────────────────────────────────────────────────

class _VillageTile extends StatelessWidget {
  final VillageInterestRow village;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _VillageTile({
    required this.village,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Village header
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    village.villageName,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  _inrFmt.format(village.totalInterest),
                  style: AppTextStyles.amountSmall.copyWith(
                    color: const Color(0xFF4338CA),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Group rows (animated)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            color: AppColors.surface,
            child: Column(
              children: village.groups.map((g) => _GroupRow(group: g)).toList(),
            ),
          ),
        ),

        const Divider(height: 1, indent: 16),
      ],
    );
  }
}

// ─── Group row ────────────────────────────────────────────────────────────────

class _GroupRow extends StatelessWidget {
  final GroupInterestRow group;

  const _GroupRow({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 52, right: 16, top: 10, bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.people_outline,
              size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(group.groupName,
                style: AppTextStyles.bodySecondary),
          ),
          Text(
            _inrFmt.format(group.interest),
            style: AppTextStyles.amountSmall.copyWith(
              fontSize: 14,
              color: group.interest > 0
                  ? const Color(0xFF4338CA)
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
