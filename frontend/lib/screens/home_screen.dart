import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shg_portal/l10n/app_localizations.dart';

import '../models/group.dart';
import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_drawer.dart';
import '../widgets/connectivity_bar.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/sofa_logo.dart';

// Extracts meeting day from group names like "Iyarkai - SL- 14" → 14
final _dayRegex = RegExp(r'[-\s]+(\d{1,2})\s*$');

int? _extractDay(String name) {
  final m = _dayRegex.firstMatch(name);
  if (m == null) return null;
  return int.tryParse(m.group(1)!);
}

enum _SortMode { date, groupName, village }

String _sortLabel(_SortMode mode, AppLocalizations l10n) {
  switch (mode) {
    case _SortMode.date:
      return l10n.sortByDate;
    case _SortMode.groupName:
      return l10n.sortByGroupName;
    case _SortMode.village:
      return l10n.sortByVillage;
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  _SortMode _sortMode = _SortMode.date;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupsAsync = ref.watch(groupsProvider);
    final entriesAsync = ref.watch(entriesProvider);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      drawer: isTablet ? null : const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/entries/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: l10n.newEntry,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle, style: AppTextStyles.appBarTitle),
            Text(l10n.appSubtitle, style: AppTextStyles.appBarSubtitle),
          ],
        ),
        actions: [
          if (!isTablet)
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: l10n.dashboardTooltip,
              onPressed: () => context.push('/dashboard'),
            ),
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBar(),
          Expanded(
            child: groupsAsync.when(
              loading: _buildLoading,
              error: (_, __) => Center(
                child: Text(l10n.couldNotLoadGroups,
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.error)),
              ),
              data: (groups) =>
                  _buildContent(context, l10n, groups, entriesAsync),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ShimmerCard(height: 200, margin: EdgeInsets.only(bottom: 14)),
            ShimmerCard(height: 44, margin: EdgeInsets.only(bottom: 16)),
            ShimmerCard(height: 76, margin: EdgeInsets.only(bottom: 8)),
            ShimmerCard(height: 76, margin: EdgeInsets.only(bottom: 8)),
            ShimmerCard(height: 76, margin: EdgeInsets.only(bottom: 8)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    List<Group> groups,
    AsyncValue<List<MonthEntry>> entriesAsync,
  ) {
    final now = DateTime.now();
    final Map<int, MonthEntry> entryMap = {};
    double thisMonthSavings = 0;
    double loansDisbursed = 0;
    double allTimeSavings = 0;

    // Use DateTime.parse for safe month comparison (handles both "YYYY-MM-01"
    // and "YYYY-MM-01T00:00:00" formats that the API may return)
    entriesAsync.maybeWhen(
      data: (entries) {
        for (final e in entries) {
          allTimeSavings += e.savingsCollected;
          final entryDate = DateTime.tryParse(e.entryMonth);
          if (entryDate != null &&
              entryDate.year == now.year &&
              entryDate.month == now.month) {
            entryMap[e.groupId] = e;
            thisMonthSavings += e.savingsCollected;
            loansDisbursed += e.sofaLoanDisbursed;
          }
        }
      },
      orElse: () {},
    );

    final q = _searchQuery.toLowerCase();
    final filtered = q.isEmpty
        ? groups
        : groups
            .where((g) =>
                g.name.toLowerCase().contains(q) ||
                g.villageName.toLowerCase().contains(q))
            .toList();

    final today = now.day;

    final todayGroups = <Group>[];
    final restGroups = <Group>[];
    for (final g in filtered) {
      final day = _extractDay(g.name);
      if (day == today) {
        todayGroups.add(g);
      } else {
        restGroups.add(g);
      }
    }

    todayGroups.sort((a, b) => a.name.compareTo(b.name));
    restGroups.sort((a, b) {
      switch (_sortMode) {
        case _SortMode.date:
          final da = _extractDay(a.name) ?? 99;
          final db = _extractDay(b.name) ?? 99;
          if (da != db) return da.compareTo(db);
          final nc = a.name.compareTo(b.name);
          if (nc != 0) return nc;
          return a.villageName.compareTo(b.villageName);
        case _SortMode.groupName:
          return a.name.compareTo(b.name);
        case _SortMode.village:
          final vc = a.villageName.compareTo(b.villageName);
          if (vc != 0) return vc;
          return a.name.compareTo(b.name);
      }
    });

    final entriesLoading = entriesAsync.isLoading;
    final monthName = DateFormat('MMM').format(now).toUpperCase();

    return RefreshIndicator(
      onRefresh: () => ref.read(groupsProvider.notifier).refreshFromServer(),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCard(
                        now: now,
                        thisMonthSavings: thisMonthSavings,
                        groupsThisMonth: entryMap.length,
                        totalGroups: groups.length,
                        loansDisbursed: loansDisbursed,
                        allTimeSavings: allTimeSavings,
                        loading: entriesLoading,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              decoration: InputDecoration(
                                hintText: l10n.searchGroupsHint,
                                prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.clear_rounded,
                                            size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(
                                              () => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<_SortMode>(
                            initialValue: _sortMode,
                            onSelected: (m) =>
                                setState(() => _sortMode = m),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                border: Border.all(
                                    color: AppColors.primary,
                                    width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.swap_vert_rounded,
                                      size: 16,
                                      color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sort: ${_sortLabel(_sortMode, l10n)}',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            itemBuilder: (_) => [
                              _sortItem(
                                  _SortMode.date,
                                  l10n.sortByDate,
                                  Icons.calendar_today_rounded,
                                  _sortMode),
                              _sortItem(
                                  _SortMode.groupName,
                                  l10n.sortByGroupName,
                                  Icons.group_outlined,
                                  _sortMode),
                              _sortItem(
                                  _SortMode.village,
                                  l10n.sortByVillage,
                                  Icons.location_on_rounded,
                                  _sortMode),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // TODAY section
              if (todayGroups.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionDivider(
                    label:
                        '📅 ${l10n.sectionToday} · $today $monthName',
                    isToday: true,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _GroupTile(
                        group: todayGroups[i],
                        entry: entryMap[todayGroups[i].id],
                        isToday: true,
                        now: now,
                        l10n: l10n,
                      ),
                      childCount: todayGroups.length,
                    ),
                  ),
                ),
              ],

              // REST OF MONTH section
              if (restGroups.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionDivider(
                    label: 'REST OF $monthName',
                    isToday: false,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _GroupTile(
                        group: restGroups[i],
                        entry: entryMap[restGroups[i].id],
                        isToday: false,
                        now: now,
                        l10n: l10n,
                      ),
                      childCount: restGroups.length,
                    ),
                  ),
                ),
              ],

              // All groups (when no today split applies)
              if (todayGroups.isEmpty && restGroups.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l10n.noGroupsFound,
                          style: AppTextStyles.bodySecondary),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<_SortMode> _sortItem(
    _SortMode value,
    String label,
    IconData icon,
    _SortMode current,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: current == value
                  ? AppColors.primary
                  : AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                fontWeight: current == value
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: current == value
                    ? AppColors.primary
                    : AppColors.textPrimary,
              )),
          if (current == value) ...[
            const Spacer(),
            const Icon(Icons.check_rounded,
                size: 16, color: AppColors.primary),
          ],
        ],
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final DateTime now;
  final double thisMonthSavings;
  final int groupsThisMonth;
  final int totalGroups;
  final double loansDisbursed;
  final double allTimeSavings;
  final bool loading;
  final AppLocalizations l10n;

  const _HeroCard({
    required this.now,
    required this.thisMonthSavings,
    required this.groupsThisMonth,
    required this.totalGroups,
    required this.loansDisbursed,
    required this.allTimeSavings,
    required this.loading,
    required this.l10n,
  });

  String _fmt(double v) => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(v);

  @override
  Widget build(BuildContext context) {
    final amtText = loading ? '—' : _fmt(thisMonthSavings);
    final loansText = loading ? '—' : _fmt(loansDisbursed);
    final allTimeText = loading ? '—' : _fmt(allTimeSavings);
    final groupsText = loading
        ? '— / $totalGroups groups'
        : '$groupsThisMonth / $totalGroups groups';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A5C3A), Color(0xFF0C3320)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A5C3A).withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -28,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: -35,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SofaLogo(size: 36),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'SOFA Sittilingi',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xCCFFFFFF),
                                height: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 11, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM yyyy').format(now),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.thisMonthSavings,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0x88FFFFFF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        amtText,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            label: 'Groups this month',
                            value: groupsText,
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 24,
                          thickness: 1,
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'Loans disbursed',
                            value: loansText,
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 24,
                          thickness: 1,
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'All-time savings',
                            value: allTimeText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0x77FFFFFF),
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xEEFFFFFF),
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Section divider ───────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  final String label;
  final bool isToday;
  const _SectionDivider({required this.label, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isToday
                    ? const Color(0xFFC8A000)
                    : AppColors.textTertiary,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ── Group tile ────────────────────────────────────────────────────────────────

class _GroupTile extends StatelessWidget {
  final Group group;
  final MonthEntry? entry;
  final bool isToday;
  final DateTime now;
  final AppLocalizations l10n;

  const _GroupTile({
    required this.group,
    required this.entry,
    required this.isToday,
    required this.now,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hasEntry = entry != null;
    final hasWarning = hasEntry && entry!.warningFlags.isNotEmpty;
    final isPending =
        hasEntry && entry!.syncStatus == SyncStatus.pendingSync;
    final day = _extractDay(group.name);

    final Color badgeBg;
    final Color badgeText;
    final Color leftBorderColor;
    final double leftBorderWidth;

    if (isToday) {
      badgeBg = const Color(0xFFFEF9C3);
      badgeText = const Color(0xFFC8A000);
      leftBorderColor = const Color(0xFFFDE68A);
      leftBorderWidth = 3;
    } else if (isPending) {
      badgeBg = const Color(0xFFFFF3E8);
      badgeText = const Color(0xFFD4621A);
      leftBorderColor = const Color(0xFFD4621A);
      leftBorderWidth = 3;
    } else if (hasWarning) {
      badgeBg = const Color(0xFFFEFCE8);
      badgeText = const Color(0xFF92400E);
      leftBorderColor = AppColors.warningIcon;
      leftBorderWidth = 3;
    } else {
      badgeBg = const Color(0xFFE8F5EE);
      badgeText = AppColors.primary;
      leftBorderColor = AppColors.border;
      leftBorderWidth = 1;
    }

    final Color dotColor = !hasEntry
        ? AppColors.textTertiary
        : hasWarning
            ? AppColors.warningIcon
            : isPending
                ? AppColors.pending
                : AppColors.synced;

    final String? savingsText = hasEntry
        ? NumberFormat.currency(
                locale: 'en_IN', symbol: '₹', decimalDigits: 0)
            .format(entry!.savingsCollected)
        : null;

    final monthAbbr = DateFormat('MMM').format(now);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFFFFF8EC)
            : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
              color: leftBorderColor, width: leftBorderWidth),
          top: BorderSide(
              color: isToday
                  ? const Color(0xFFFDE68A)
                  : AppColors.border),
          right: BorderSide(
              color: isToday
                  ? const Color(0xFFFDE68A)
                  : AppColors.border),
          bottom: BorderSide(
              color: isToday
                  ? const Color(0xFFFDE68A)
                  : AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => hasEntry
            ? context.push('/entries/edit', extra: entry)
            : context.push('/ledger/${group.id}'),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 13, vertical: 12),
          child: Row(
            children: [
              // Date badge
              if (day != null)
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: badgeText.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: badgeText,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        monthAbbr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeText.withValues(alpha: 0.7),
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.group_rounded,
                      color: AppColors.primary, size: 22),
                ),

              const SizedBox(width: 13),

              // Name + village
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(group.name,
                              style: AppTextStyles.title,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8A000),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'TODAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13,
                            color: AppColors.textTertiary),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            group.villageName,
                            style: AppTextStyles.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (!hasEntry) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.notYetCollected,
                        style: AppTextStyles.label.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Amount + dot
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (savingsText != null)
                    Text(savingsText,
                        style: AppTextStyles.amountSmall),
                  const SizedBox(height: 5),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
