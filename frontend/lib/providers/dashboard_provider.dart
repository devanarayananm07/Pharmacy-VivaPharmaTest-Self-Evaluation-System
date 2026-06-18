import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class DashboardState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? data;

  DashboardState({this.isLoading = false, this.error, this.data});

  DashboardState copyWith({bool? isLoading, String? error, Map<String, dynamic>? data}) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return DashboardState();
  }

  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiService = ref.read(apiServiceProvider);
      final auth = ref.read(authProvider);
      final employeeId = auth.employeeId ?? 'PQ-11204';
      
      final data = await apiService.getDashboardStats(employeeId);
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
