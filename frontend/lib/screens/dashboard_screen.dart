import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../theme/obsidian_theme.dart';
import '../providers/dashboard_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/assessment_provider.dart';
import '../services/api_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedQuestionCount = 10;
  String _selectedStore = 'All';
  String _selectedDays = 'All';

  bool _isStartingViva = false;
  bool _canResume = false;
  List<Map<String, String>> _savedExams = [];

  List<String> _stores = ['All'];
  List<String> _examDays = ['All'];
  final List<int> _questionCounts = [5, 10, 15, 20, 25, 30];

  bool _isLoadingFilters = true;
  bool _isLoadingStats = true;

  int _examsAttended = 0;
  double _avgMark = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(dashboardProvider.notifier).fetchDashboard();
      _checkResumeSession();
      _loadFilters();
      _loadStats();
    });
  }

  Future<void> _checkResumeSession() async {
    final notifier = ref.read(assessmentProvider.notifier);
    final exams = await notifier.getSavedAssessments();
    if (mounted) {
      setState(() {
        _savedExams = exams;
        _canResume = exams.isNotEmpty;
      });
    }
  }

  Future<void> _loadFilters() async {
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

      final storesList = storesSet.toList()..sort();
      final daysList = daysSet.toList()..sort();

      if (mounted) {
        setState(() {
          _stores = ['All', ...storesList];
          _examDays = ['All', ...daysList];
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

  Future<void> _loadStats() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final auth = ref.read(authProvider);
      final employeeId = auth.employeeId ?? '';

      if (employeeId.isNotEmpty) {
        final attempts = await apiService.getAttempts(employeeId: employeeId);
        double sumPercent = 0.0;
        int completedCount = 0;

        for (var a in attempts) {
          if (a['status'] == 'Completed') {
            sumPercent += (a['percent'] as num).toDouble();
            completedCount++;
          }
        }

        if (mounted) {
          setState(() {
            _examsAttended = completedCount;
            _avgMark = completedCount > 0 ? double.parse((sumPercent / completedCount).toStringAsFixed(1)) : 0.0;
            _isLoadingStats = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingStats = false);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  void _handleStartViva() async {
    final selectedStoreText = _selectedStore == 'All' ? 'All' : _selectedStore;
    final selectedDaysText = _selectedDays == 'All' ? 'All' : _selectedDays;

    for (var exam in _savedExams) {
      if (exam['store'] == selectedStoreText && exam['days'] == selectedDaysText) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ObsidianTheme.surfaceContainer,
            title: const Text('Exam Filter Conflict', style: TextStyle(color: ObsidianTheme.onSurface, fontWeight: FontWeight.bold)),
            content: Text(
              'You already have an in-progress exam with the selected Store ($selectedStoreText) and Day ($selectedDaysText). Please resume or discard that exam below, or choose different filters to start a new one.',
              style: const TextStyle(color: ObsidianTheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    setState(() => _isStartingViva = true);
    final success = await ref.read(assessmentProvider.notifier).startAssessment(
      count: _selectedQuestionCount,
      difficulty: 'Easy',
      store: _selectedStore == 'All' ? null : _selectedStore,
      days: _selectedDays == 'All' ? null : _selectedDays,
    );
    setState(() => _isStartingViva = false);

    if (success && mounted) {
      context.push('/assessment').then((_) {
        ref.read(dashboardProvider.notifier).fetchDashboard();
        _checkResumeSession();
        _loadStats();
      });
    } else if (mounted) {
      final error = ref.read(assessmentProvider).error ?? 'Failed to load questions';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: ObsidianTheme.error),
      );
    }
  }

  void _handleDiscardSpecificResume(String attemptId) async {
    await ref.read(assessmentProvider.notifier).clearSpecificSession(attemptId);
    _checkResumeSession();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved exam session discarded.'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final data = dashboardState.data;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const TopAppBar(
        title: 'PharmaQ',
        showBackButton: false,
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: dashboardState.isLoading && data == null && _isLoadingFilters && _isLoadingStats
          ? const Center(child: CircularProgressIndicator(color: ObsidianTheme.primary))
          : dashboardState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: ObsidianTheme.error, size: 48),
                      const SizedBox(height: 16),
                      Text('Error loading dashboard: ${dashboardState.error}', style: const TextStyle(color: ObsidianTheme.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(dashboardProvider.notifier).fetchDashboard();
                          _loadFilters();
                          _loadStats();
                        },
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Section
                      Text(
                        'Welcome back, ${authState.employeeName ?? 'Staff Member'}.',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${authState.role}  •  ${authState.workArea}',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // Mini Bento Stats Dashboard
                      _isLoadingStats
                          ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: CircularProgressIndicator(color: ObsidianTheme.primary)))
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildBentoStatCard(
                                    'Exams Attended',
                                    '$_examsAttended',
                                    Icons.assignment_outlined,
                                    'Completed',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildBentoStatCard(
                                    'Average Mark',
                                    '${_avgMark.toStringAsFixed(1)}%',
                                    Icons.analytics_outlined,
                                    'Avg Score',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildBentoStatCard(
                                    'Active Role',
                                    authState.role ?? 'Staff',
                                    Icons.badge_outlined,
                                    authState.designation ?? 'Pharmacist',
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 32),

                      // Config & Start Exam Card (always visible!)
                      _isLoadingFilters
                          ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: CircularProgressIndicator(color: ObsidianTheme.primary)))
                          : Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Configure Exam',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Configure criteria to filter questions and test your clinical pharmacology knowledge.',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Store Dropdown
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedStore,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Store',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    items: _stores
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                            ))
                                        .toList(),
                                    onChanged: (val) => setState(() => _selectedStore = val!),
                                  ),
                                  const SizedBox(height: 16),

                                  // Question Count Dropdown
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedQuestionCount,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Number of Questions',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    items: _questionCounts
                                        .map((c) => DropdownMenuItem(
                                              value: c,
                                              child: Text('$c Questions', style: const TextStyle(fontSize: 13)),
                                            ))
                                        .toList(),
                                    onChanged: (val) => setState(() => _selectedQuestionCount = val!),
                                  ),
                                  const SizedBox(height: 16),

                                  // Exam Day Dropdown
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedDays,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Exam Day',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    items: _examDays
                                        .map((d) => DropdownMenuItem(
                                              value: d,
                                              child: Text(d, style: const TextStyle(fontSize: 13)),
                                            ))
                                        .toList(),
                                    onChanged: (val) => setState(() => _selectedDays = val!),
                                  ),
                                  const SizedBox(height: 28),

                                  // Start Exam Button
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: _isStartingViva ? null : _handleStartViva,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Theme.of(context).colorScheme.brightness == Brightness.dark
                                            ? const Color(0xFF0A0012)
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: _isStartingViva
                                          ? SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context).colorScheme.brightness == Brightness.dark
                                                    ? ObsidianTheme.background
                                                    : Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.play_circle_outline, size: 22),
                                      label: const Text(
                                        'Start Exam',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                      // In-progress Exam Log (shown below the config card)
                      if (_canResume) ...[
                        _buildResumeLogSection(),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBentoStatCard(String label, String value, IconData icon, String subtext) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: isDark ? ObsidianTheme.tertiary : const Color(0xFF059669),
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getOrdinal(int number) {
    if (number <= 0) return '$number';
    final lastDigit = number % 10;
    final lastTwoDigits = number % 100;
    if (lastTwoDigits >= 11 && lastTwoDigits <= 13) {
      return '${number}th';
    }
    switch (lastDigit) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  Widget _buildResumeLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(Icons.history_toggle_off, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text(
              'In-Progress Exam Logs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: ObsidianTheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._savedExams.asMap().entries.map((entry) => _buildResumeBannerFor(entry.value, entry.key + 1)),
      ],
    );
  }

  Widget _buildLogDetailItem(IconData icon, String label, String value, {bool isSuccess = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSuccess ? ObsidianTheme.tertiary : Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResumeBannerFor(Map<String, String> exam, int index) {
    final attemptId = exam['attemptId'] ?? '';
    final store = exam['store'] ?? 'All';
    final days = exam['days'] ?? 'All';
    final difficulty = exam['difficulty'] ?? 'Easy';
    final totalQuestions = exam['totalQuestions'] ?? '0';
    final attendedQuestions = exam['attendedQuestions'] ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getOrdinal(index)} Saved Exam',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  difficulty.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLogDetailItem(Icons.store, 'Store', store),
              ),
              Expanded(
                child: _buildLogDetailItem(Icons.today, 'Day', days),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLogDetailItem(Icons.quiz, 'Total Questions', totalQuestions),
              ),
              Expanded(
                child: _buildLogDetailItem(
                  Icons.check_circle_outline,
                  'Attended',
                  '$attendedQuestions / $totalQuestions',
                  isSuccess: int.tryParse(attendedQuestions) == int.tryParse(totalQuestions) && int.parse(totalQuestions) > 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await ref.read(assessmentProvider.notifier).tryResumeViva(targetAttemptId: attemptId);
                    if (success && mounted) {
                      context.push('/assessment').then((_) {
                        ref.read(dashboardProvider.notifier).fetchDashboard();
                        _checkResumeSession();
                        _loadStats();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.brightness == Brightness.dark
                        ? const Color(0xFF0A0012)
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Resume', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleDiscardSpecificResume(attemptId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ObsidianTheme.error,
                    side: const BorderSide(color: ObsidianTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Discard'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
