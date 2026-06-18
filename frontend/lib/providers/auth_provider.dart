import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? employeeId;
  final String? employeeName;
  final String? role; // Admin, Mentor, Employee
  final String? designation;
  final String? workArea;
  final bool forcePasswordChange;

  AuthState({
    required this.status,
    this.errorMessage,
    this.employeeId,
    this.employeeName,
    this.role,
    this.designation,
    this.workArea,
    this.forcePasswordChange = false,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
  factory AuthState.authenticating() => AuthState(status: AuthStatus.authenticating);
  factory AuthState.unauthenticated() => AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String msg) => AuthState(status: AuthStatus.error, errorMessage: msg);
  
  factory AuthState.authenticated({
    required String employeeId,
    required String employeeName,
    required String role,
    required String designation,
    required String workArea,
    bool forcePasswordChange = false,
  }) => AuthState(
    status: AuthStatus.authenticated,
    employeeId: employeeId,
    employeeName: employeeName,
    role: role,
    designation: designation,
    workArea: workArea,
    forcePasswordChange: forcePasswordChange,
  );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    checkSession();
    return AuthState.initial();
  }

  Future<void> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final employeeId = prefs.getString('employee_id');
      final name = prefs.getString('employee_name');
      final role = prefs.getString('employee_role');
      final designation = prefs.getString('employee_designation');
      final workArea = prefs.getString('employee_work_area');
      final forcePasswordChange = prefs.getBool('force_password_change') ?? false;

      if (token != null && employeeId != null) {
        state = AuthState.authenticated(
          employeeId: employeeId,
          employeeName: name ?? 'Pharmacy Staff',
          role: role ?? 'Employee',
          designation: designation ?? 'Pharmacist',
          workArea: workArea ?? 'General Store',
          forcePasswordChange: forcePasswordChange,
        );
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (_) {
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login(String employeeId, String password) async {
    state = AuthState.authenticating();
    try {
      final apiService = ref.read(apiServiceProvider);
      final res = await apiService.login(employeeId, password);
      
      state = AuthState.authenticated(
        employeeId: res['employee_id'],
        employeeName: res['name'] ?? 'Pharmacy Staff',
        role: res['role'] ?? 'Employee',
        designation: res['designation'] ?? 'Pharmacist',
        workArea: res['work_area'] ?? 'General Store',
        forcePasswordChange: res['force_password_change'] == true,
      );
      return true;
    } catch (e) {
      String cleanError = e.toString();
      if (cleanError.startsWith("Exception: ")) {
        cleanError = cleanError.substring(10);
      }
      state = AuthState.error(cleanError);
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.changePassword(newPassword);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('force_password_change', false);
      
      if (state.status == AuthStatus.authenticated) {
        state = AuthState.authenticated(
          employeeId: state.employeeId!,
          employeeName: state.employeeName!,
          role: state.role!,
          designation: state.designation!,
          workArea: state.workArea!,
          forcePasswordChange: false,
        );
      }
      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.logout();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('force_password_change');
    
    state = AuthState.unauthenticated();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class ProfileAvatarNotifier extends Notifier<String> {
  @override
  String build() {
    _init();
    return '';
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAvatar = prefs.getString('profile_avatar_url');
      if (savedAvatar != null) {
        state = savedAvatar;
      }
    } catch (_) {}
  }

  Future<void> setAvatar(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_avatar_url', url);
      state = url;
    } catch (_) {}
  }
}

final profileAvatarProvider = NotifierProvider<ProfileAvatarNotifier, String>(() {
  return ProfileAvatarNotifier();
});
