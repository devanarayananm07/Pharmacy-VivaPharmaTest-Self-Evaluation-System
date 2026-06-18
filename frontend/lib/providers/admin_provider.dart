import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// 1. Employees provider (Admin)
final employeesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getEmployees();
});

// 2. Questions list provider (Admin/Mentor)
final adminQuestionsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getQuestions();
});

// 3. Admin actions notifier
class AdminNotifier extends Notifier<void> {
  @override
  void build() {
    return;
  }

  // Toggle role between Employee and Mentor
  Future<bool> toggleEmployeeRole(Map<String, dynamic> employee, bool currentIsMentor) async {
    final apiService = ref.read(apiServiceProvider);
    final updatedEmployee = Map<String, dynamic>.from(employee);
    if (currentIsMentor) {
      updatedEmployee['designation'] = 'Pharmacy Staff';
      updatedEmployee['role'] = 'Employee';
      updatedEmployee['employee_role'] = 'Employee';
      updatedEmployee['privilege'] = 'Employee';
    } else {
      updatedEmployee['designation'] = 'Clinical Mentor';
      updatedEmployee['role'] = 'Mentor';
      updatedEmployee['employee_role'] = 'Mentor';
      updatedEmployee['privilege'] = 'Mentor';
    }
    
    try {
      await apiService.updateEmployee(updatedEmployee);
      ref.invalidate(employeesProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Create Question
  Future<bool> createQuestion(Map<String, dynamic> question) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.createQuestion(question);
      ref.invalidate(adminQuestionsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Update Question
  Future<bool> updateQuestion(Map<String, dynamic> question) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.updateQuestion(question);
      ref.invalidate(adminQuestionsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Delete Question
  Future<bool> deleteQuestion(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.deleteQuestion(id);
      ref.invalidate(adminQuestionsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final adminProvider = NotifierProvider<AdminNotifier, void>(() {
  return AdminNotifier();
});
