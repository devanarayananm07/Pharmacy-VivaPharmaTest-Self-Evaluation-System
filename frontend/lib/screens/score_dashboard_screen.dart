import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../components/pharmaq_card.dart';
import '../providers/score_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ScoreDashboardScreen extends ConsumerStatefulWidget {
  const ScoreDashboardScreen({super.key});

  @override
  ConsumerState<ScoreDashboardScreen> createState() => _ScoreDashboardScreenState();
}

class _ScoreDashboardScreenState extends ConsumerState<ScoreDashboardScreen> {
  List<String> _stores = ['All'];
  List<String> _daysList = ['All'];
  bool _isLoadingFilters = true;

  String _selectedStoreFilter = 'All';
  String _selectedDayFilter = 'All';
  bool _hasLoadedEmployeeScores = false;
  bool _hasLoadedSelfScores = false;
  bool _hasLoadedMentorScores = false;

  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _backgroundColor => Theme.of(context).colorScheme.surface;
  Color get _surfaceContainerHighest => Theme.of(context).colorScheme.surfaceContainerHighest;
  Color get _surfaceContainerLowest => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF09090b) : const Color(0xFFFFFFFF);
  Color get _outlineVariant => Theme.of(context).colorScheme.outlineVariant;
  Color get _tertiaryColor => Theme.of(context).colorScheme.secondary;
  Color get _errorColor => Theme.of(context).colorScheme.error;
  Color get _onSurfaceColor => Theme.of(context).colorScheme.onSurface;
  Color get _onSurfaceVariantColor => Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.role == 'Admin') {
          ref.read(scoreFiltersProvider.notifier).setViewMode('employees');
        } else {
          ref.read(scoreFiltersProvider.notifier).reset();
        }
      }
    });
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final questions = await apiService.getQuestions();
      final storesSet = <String>{};
      final daysSet = <String>{};

      for (var q in questions) {
        if (q['store'] != null) {
          final s = q['store'].toString().trim();
          if (s.isNotEmpty) storesSet.add(s);
        }
        if (q['days'] != null) {
          final d = q['days'].toString().trim();
          if (d.isNotEmpty) daysSet.add(d);
        }
      }

      final sortedStores = storesSet.toList()..sort();
      final sortedDays = daysSet.toList()..sort();

      if (mounted) {
        setState(() {
          _stores = ['All', ...sortedStores];
          _daysList = ['All', ...sortedDays];
          _isLoadingFilters = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingFilters = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(scoreFiltersProvider);
    final authState = ref.watch(authProvider);

    // Before Load Score is clicked for self scores (Employee or Mentor/Admin self), show overall insights ('All', 'All').
    final queryFilters = filters.viewMode == 'self' && !_hasLoadedSelfScores
        ? ScoreFilters(store: 'All', days: 'All', viewMode: 'self')
        : filters;

    final historyAsync = ref.watch(scoreHistoryProvider(queryFilters));
    final bool showPrompt = (filters.viewMode == 'employees' && !_hasLoadedEmployeeScores) ||
                            (filters.viewMode == 'mentors' && !_hasLoadedMentorScores);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const TopAppBar(
        title: 'PharmaQ Scores',
        showBackButton: false,
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Weekly Performance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: _onSurfaceColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review clinical proficiency and identification accuracy.',
                style: TextStyle(
                  fontSize: 14,
                  color: _onSurfaceVariantColor,
                ),
              ),
              const SizedBox(height: 20),

              // View Mode Toggle (only for Admin/Mentor!)
              if (authState.role == 'Admin' || authState.role == 'Mentor') ...[
                Builder(
                  builder: (context) {
                    final List<Map<String, String>> segments = [
                      if (authState.role != 'Admin')
                        {'label': 'My Scores', 'value': 'self'},
                      if (authState.role == 'Admin')
                        {'label': 'Mentor Scores', 'value': 'mentors'},
                      if (authState.role == 'Admin' || authState.role == 'Mentor')
                        {'label': 'Employee Scores', 'value': 'employees'},
                    ];

                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _outlineVariant),
                      ),
                      child: Row(
                        children: segments.map((seg) {
                          final isSelected = filters.viewMode == seg['value'];
                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                ref.read(scoreFiltersProvider.notifier).setViewMode(seg['value']!);
                                setState(() {
                                  _hasLoadedSelfScores = false;
                                  _hasLoadedEmployeeScores = false;
                                  _hasLoadedMentorScores = false;
                                  _selectedStoreFilter = 'All';
                                  _selectedDayFilter = 'All';
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? _primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    seg['label']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isSelected
                                          ? (Theme.of(context).brightness == Brightness.dark
                                              ? const Color(0xFF0A0012)
                                              : Colors.white)
                                          : _onSurfaceColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 20),
              ],

              // Filter Dropdowns
              _isLoadingFilters
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _primaryColor),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('store_${filters.viewMode}_$_selectedStoreFilter'),
                            initialValue: _selectedStoreFilter,
                            isExpanded: true,
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), labelText: 'Filter Store'),
                            dropdownColor: _surfaceContainerHighest,
                            items: _stores.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedStoreFilter = val;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('days_${filters.viewMode}_$_selectedDayFilter'),
                            initialValue: _selectedDayFilter,
                            isExpanded: true,
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), labelText: 'Filter Day'),
                            dropdownColor: _surfaceContainerHighest,
                            items: _daysList.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedDayFilter = val;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

              // Load Score Button
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (filters.viewMode == 'self') {
                        _hasLoadedSelfScores = true;
                      } else {
                        _hasLoadedEmployeeScores = true;
                      }
                    });
                    ref.read(scoreFiltersProvider.notifier).setStore(_selectedStoreFilter);
                    ref.read(scoreFiltersProvider.notifier).setDays(_selectedDayFilter);
                  },
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    'Load Score',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (showPrompt)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_alt_outlined, size: 64, color: _onSurfaceVariantColor),
                        const SizedBox(height: 16),
                        Text(
                          'Configure Filters to Load Scores',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _onSurfaceColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          filters.viewMode == 'mentors'
                              ? 'Select the Store and Day above, then click "Load Score" to query mentor results.'
                              : filters.viewMode == 'employees'
                                  ? 'Select the Store and Day above, then click "Load Score" to query employee results.'
                                  : 'Select the Store and Day above, then click "Load Score" to view your results.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _onSurfaceVariantColor, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
              else
                historyAsync.when(
                  loading: () => Center(child: Padding(padding: const EdgeInsets.all(32.0), child: CircularProgressIndicator(color: _primaryColor))),
                  error: (err, _) => Center(child: Text('Error loading scores: $err', style: TextStyle(color: _errorColor))),
                  data: (stats) {
                    if (stats.totalAttempts == 0) {
                      final isSelf = filters.viewMode == 'self';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isSelf ? Icons.leaderboard_outlined : Icons.assignment_outlined, size: 64, color: _onSurfaceVariantColor),
                              const SizedBox(height: 16),
                              Text(
                                isSelf
                                    ? 'No Completed Exams Found'
                                    : filters.viewMode == 'mentors'
                                        ? 'No Mentor Exams Found'
                                        : 'No Employee Exams Found',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _onSurfaceColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isSelf
                                    ? 'Complete at least one exam on the Home tab to view score trends and proficiency reports.'
                                    : filters.viewMode == 'mentors'
                                        ? 'No exam attempts matching the selected filters were completed by mentors.'
                                        : 'No exam attempts matching the selected filters were completed by other employees.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _onSurfaceVariantColor, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if ((filters.viewMode == 'employees' || filters.viewMode == 'mentors') && (authState.role == 'Admin' || authState.role == 'Mentor')) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildEmployeeScoresList(stats.attempts, filters.viewMode == 'mentors'),
                          const SizedBox(height: 48),
                        ],
                      );
                    }

                    final bool hideTable = filters.viewMode == 'self' && !_hasLoadedSelfScores;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // History Attempt List (Table Wise Marks)
                        if (!hideTable) ...[
                          _buildRecentVivasList(stats.attempts, authState),
                          const SizedBox(height: 24),
                        ],

                        // Circular Mastery Progress
                        _buildMasteryCard(stats),
                        const SizedBox(height: 16),

                        // Score Metric Grid
                        Row(
                          children: [
                            Expanded(child: _buildStatTile('Average Score', '${stats.avgScore}%', Icons.analytics, 'Passing is 70%', true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatTile('Success Rate', '${stats.successRate}%', Icons.verified, '${stats.passedAttempts} Passed', true)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildStatTile('Total Exams', '${stats.totalAttempts}', Icons.assignment, 'Completed sessions', true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatTile('Failing Exams', '${stats.totalAttempts - stats.passedAttempts}', Icons.dangerous, 'Requires study', false)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Score Trend Chart
                        _buildTrendCard(stats),
                        const SizedBox(height: 48),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMasteryCard(ScoreStats stats) {
    final double value = stats.avgScore / 100.0;
    return PharmaQCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMPOSITE MASTERY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Performance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: _onSurfaceVariantColor,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Your clinical diagnostic accuracy is currently at '),
                      TextSpan(
                        text: '${stats.avgScore}%',
                        style: TextStyle(color: _tertiaryColor, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '. Review study materials to further optimize accuracy ratings.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: _outlineVariant,
                  color: _primaryColor,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${stats.avgScore.round()}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _onSurfaceColor,
                      ),
                    ),
                    Text(
                      'OVERALL',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: _onSurfaceVariantColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String title, String score, IconData icon, String label, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        border: Border.all(color: _outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: _onSurfaceVariantColor),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _onSurfaceVariantColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            score,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _onSurfaceColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isPositive ? _tertiaryColor : _errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(ScoreStats stats) {
    return PharmaQCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERFORMANCE TREND',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: _onSurfaceVariantColor,
                ),
              ),
              Text(
                'Avg: ${stats.avgScore}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (stats.trends.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'No completed attempts found to plot trends.',
                  style: TextStyle(color: _onSurfaceVariantColor),
                ),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(stats.trends.length, (index) {
                  final score = stats.trends[index];
                  final label = 'V${index + 1}';
                  return _buildChartBar(score / 100.0, label, index == stats.trends.length - 1);
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double heightFactor, String label, bool isLatest) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 90 * heightFactor,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isLatest ? _primaryColor : _primaryColor.withValues(alpha: heightFactor * 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
              color: isLatest ? _onSurfaceColor : _onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentVivasList(List<dynamic> attempts, AuthState authState) {
    final isAdminOrMentor = authState.role == 'Admin' || authState.role == 'Mentor';

    return PharmaQCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENT VIVA EXAMS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: _onSurfaceVariantColor,
            ),
          ),
          const SizedBox(height: 16),
          if (attempts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text('No recent exam attempts found.', style: TextStyle(color: _onSurfaceVariantColor))),
            )
          else
            ...attempts.map((a) {
              final scoreText = '${(a['percent'] as num).toDouble().toStringAsFixed(0)}%';
              final passed = (a['passed'] as num).toInt() == 1;
              final icon = passed ? Icons.verified : Icons.dangerous;
              final color = passed ? _tertiaryColor : _errorColor;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${a['exam_day'] ?? 'Exam'} - ${a['store'] ?? 'Store'}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _onSurfaceColor,
                              ),
                            ),
                            if (isAdminOrMentor)
                              Text(
                                'Employee ID: ${a['employee_id'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                            Text(
                              a['date'] ?? 'Unknown Date',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: _onSurfaceVariantColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      scoreText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmployeeScoresList(List<dynamic> attempts, bool isMentorView) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMentorView ? 'MENTOR EXAM SCORES' : 'EMPLOYEE EXAM SCORES',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: _onSurfaceVariantColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${attempts.length} Records',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...attempts.map((a) {
          final scoreText = '${(a['percent'] as num).toDouble().toStringAsFixed(0)}%';
          final passed = (a['passed'] as num).toInt() == 1;
          final color = passed ? _tertiaryColor : _errorColor;
          final empId = a['employee_id'] ?? 'N/A';
          final date = a['date'] ?? 'Unknown Date';
          final store = a['store'] ?? 'Store';
          final day = a['exam_day'] ?? 'Day';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _outlineVariant),
            ),
            child: Row(
              children: [
                // Status Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    passed ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Employee Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Employee ID: ',
                            style: TextStyle(
                              fontSize: 11,
                              color: _onSurfaceVariantColor,
                            ),
                          ),
                          Text(
                            empId,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.store, size: 12, color: _onSurfaceVariantColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store,
                              style: TextStyle(fontSize: 11, color: _onSurfaceColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.today, size: 12, color: _onSurfaceVariantColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              day,
                              style: TextStyle(fontSize: 11, color: _onSurfaceColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: TextStyle(fontSize: 10, color: _onSurfaceVariantColor),
                      ),
                    ],
                  ),
                ),

                // Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      scoreText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      passed ? 'PASSED' : 'FAILED',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
