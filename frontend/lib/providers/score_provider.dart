import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class ScoreFilters {
  final String store;
  final String days;
  final String viewMode; // 'self' or 'employees'

  ScoreFilters({
    this.store = 'All',
    this.days = 'All',
    this.viewMode = 'self',
  });

  ScoreFilters copyWith({
    String? store,
    String? days,
    String? viewMode,
  }) {
    return ScoreFilters(
      store: store ?? this.store,
      days: days ?? this.days,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreFilters &&
          runtimeType == other.runtimeType &&
          store == other.store &&
          days == other.days &&
          viewMode == other.viewMode;

  @override
  int get hashCode => store.hashCode ^ days.hashCode ^ viewMode.hashCode;
}

class ScoreFilterNotifier extends Notifier<ScoreFilters> {
  @override
  ScoreFilters build() {
    return ScoreFilters();
  }

  void setStore(String store) => state = state.copyWith(store: store);
  void setDays(String days) => state = state.copyWith(days: days);
  void setViewMode(String mode) => state = ScoreFilters(viewMode: mode, store: 'All', days: 'All');
  void reset() => state = ScoreFilters();
}

final scoreFiltersProvider = NotifierProvider<ScoreFilterNotifier, ScoreFilters>(() {
  return ScoreFilterNotifier();
});

class ScoreStats {
  final List<dynamic> attempts;
  final double avgScore;
  final double successRate;
  final int totalAttempts;
  final int passedAttempts;
  final List<double> trends;

  ScoreStats({
    required this.attempts,
    required this.avgScore,
    required this.successRate,
    required this.totalAttempts,
    required this.passedAttempts,
    required this.trends,
  });
}

final scoreHistoryProvider = FutureProvider.autoDispose.family<ScoreStats, ScoreFilters>((ref, filters) async {
  final apiService = ref.watch(apiServiceProvider);
  final auth = ref.watch(authProvider);
  final employeeId = auth.employeeId ?? '';

  // Retrieve attempts list
  final rawAttempts = await apiService.getAttempts();

  // Fetch all employees to resolve roles
  List<dynamic> employees = [];
  if (filters.viewMode == 'mentors' || filters.viewMode == 'employees') {
    try {
      employees = await apiService.getEmployees();
    } catch (_) {}
  }

  final Map<String, String> userRoles = {};
  for (var emp in employees) {
    final empId = emp['emp_id']?.toString().toLowerCase() ?? '';
    final designation = emp['designation']?.toString().toLowerCase() ?? '';
    final isAdmin = designation.contains('admin') || designation.contains('analyst');
    final isMentor = !isAdmin && (designation.contains('mentor') || designation.contains('supervisor'));
    if (isAdmin) {
      userRoles[empId] = 'Admin';
    } else if (isMentor) {
      userRoles[empId] = 'Mentor';
    } else {
      userRoles[empId] = 'Employee';
    }
  }

  // Filter based on viewMode
  Iterable<dynamic> filtered = rawAttempts;
  if (filters.viewMode == 'self') {
    filtered = filtered.where((a) {
      if (a['employee_id'] != employeeId) return false;
      // Exclude predefined mock attempts (att1, att2, etc.) for the self view
      final idStr = a['id']?.toString() ?? '';
      final isPredefinedMock = RegExp(r'^att\d+$').hasMatch(idStr);
      return !isPredefinedMock;
    });
  } else if (filters.viewMode == 'mentors') {
    filtered = filtered.where((a) {
      final aId = a['employee_id']?.toString().toLowerCase() ?? '';
      return aId != employeeId.toLowerCase() && userRoles[aId] == 'Mentor';
    });
  } else {
    // For 'employees'
    filtered = filtered.where((a) {
      final aId = a['employee_id']?.toString().toLowerCase() ?? '';
      final role = userRoles[aId] ?? 'Employee';
      return aId != employeeId.toLowerCase() && role == 'Employee';
    });
  }

  // Filter attempts based on UI selection
  if (filters.store != 'All') {
    filtered = filtered.where((a) => a['store'].toString().toLowerCase().contains(filters.store.toLowerCase()));
  }
  if (filters.days != 'All') {
    filtered = filtered.where((a) => a['exam_day'].toString().toLowerCase().contains(filters.days.toLowerCase()));
  }

  final attemptsList = filtered.toList();
  // Sort by date descending
  attemptsList.sort((a, b) => b['date'].toString().compareTo(a['date'].toString()));

  // Get completed attempts
  final completedAttempts = attemptsList.where((a) => a['status'] == 'Completed').toList();

  // Calculate statistics over all matching completed attempts
  double sumPercent = 0.0;
  int passedCount = 0;
  int completedCount = 0;

  for (var a in completedAttempts) {
    sumPercent += (a['percent'] as num).toDouble();
    completedCount++;
    if ((a['passed'] as num).toInt() == 1) {
      passedCount++;
    }
  }

  final double avgScore = completedCount > 0 ? (sumPercent / completedCount) : 0.0;
  final double successRate = completedCount > 0 ? (passedCount / completedCount * 100) : 0.0;

  // Trend scores (limit to latest 5 completed attempts, sorted chronologically)
  final graphAttempts = completedAttempts.take(5).toList();
  final chronological = List.from(graphAttempts)
    ..sort((a, b) => a['date'].toString().compareTo(b['date'].toString()));
  final List<double> trends = chronological
      .map((a) => (a['percent'] as num).toDouble())
      .toList();

  return ScoreStats(
    attempts: completedAttempts,
    avgScore: double.parse(avgScore.toStringAsFixed(1)),
    successRate: double.parse(successRate.toStringAsFixed(1)),
    totalAttempts: completedCount,
    passedAttempts: passedCount,
    trends: trends,
  );
});
