import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

// Core Screens
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/study_screen.dart';
import '../screens/assessment_screen.dart';

// Admin & Dashboards
import '../screens/admin_audit_logs_screen.dart';
import '../screens/compliance_reporting_screen.dart';
import '../screens/role_management_screen.dart';
import '../screens/score_dashboard_screen.dart';
import '../screens/exam_dashboard_screen.dart';
import '../screens/admin_dashboard_screen.dart';

// Batch Import & Export
import '../screens/batch_import_mapping_screen.dart';
import '../screens/batch_import_upload_screen.dart';
import '../screens/batch_import_validation_screen.dart';
import '../screens/bulk_export_config_screen.dart';
import '../screens/bulk_export_review_screen.dart';
import '../screens/bulk_export_secure_screen.dart';
import '../screens/bulk_export_success_screen.dart';

// Mentor & Q-Bank
import '../screens/mentor_dashboard_screen.dart';
import '../screens/employee_analytics_screen.dart';
import '../screens/question_bank_editor_screen.dart';
import '../screens/add_question_details_screen.dart';
import '../screens/add_question_difficulty_screen.dart';
import '../screens/add_question_success_screen.dart';

// Settings & Notifications
import '../screens/notification_center_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/push_notification_export_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/reset_password_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isResetting = state.matchedLocation == '/reset-password';
      
      final isLoggedIn = authState.status == AuthStatus.authenticated;

      // Unauthenticated state redirection
      if (!isLoggedIn) {
        // Allow access to login and reset password screens
        if (isLoggingIn || isResetting) {
          return null;
        }
        return '/login';
      }

      // Force password change guard
      if (authState.forcePasswordChange) {
        if (isResetting) {
          return null;
        }
        return '/reset-password';
      }

      // Authenticated state redirection
      if (isLoggingIn) {
        return '/dashboard';
      }

      // Restrict access based on role privileges
      final targetPath = state.matchedLocation;

      final isAdminRoute = targetPath.startsWith('/admin') ||
                           targetPath.startsWith('/import') ||
                           targetPath.startsWith('/export');
      final isMentorRoute = targetPath.startsWith('/mentor');

      if (isAdminRoute && authState.role != 'Admin') {
        return '/dashboard';
      }
      if (isMentorRoute && authState.role != 'Admin' && authState.role != 'Mentor') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final role = ref.read(authProvider).role;
          if (role == 'Admin') {
            return const AdminDashboardScreen();
          }
          return const DashboardScreen();
        },
      ),
      GoRoute(path: '/study', builder: (context, state) => const StudyScreen()),
      GoRoute(path: '/assessment', builder: (context, state) => const AssessmentScreen()),

      // Admin & Dashboards
      GoRoute(path: '/admin/audit', builder: (context, state) => const AdminAuditLogsScreen()),
      GoRoute(path: '/admin/compliance', builder: (context, state) => const ComplianceReportingScreen()),
      GoRoute(path: '/admin/roles', builder: (context, state) => const RoleManagementScreen()),
      GoRoute(path: '/dashboard/scores', builder: (context, state) => const ScoreDashboardScreen()),
      GoRoute(path: '/dashboard/exams', builder: (context, state) => const ExamDashboardScreen()),

      // Batch Import
      GoRoute(path: '/import/upload', builder: (context, state) => const BatchImportUploadScreen()),
      GoRoute(path: '/import/mapping', builder: (context, state) => const BatchImportMappingScreen()),
      GoRoute(path: '/import/validation', builder: (context, state) => const BatchImportValidationScreen()),

      // Bulk Export
      GoRoute(path: '/export/config', builder: (context, state) => const BulkExportConfigScreen()),
      GoRoute(path: '/export/review', builder: (context, state) => const BulkExportReviewScreen()),
      GoRoute(path: '/export/secure', builder: (context, state) => const BulkExportSecureScreen()),
      GoRoute(path: '/export/success', builder: (context, state) => const BulkExportSuccessScreen()),

      // Mentor & Q-Bank
      GoRoute(path: '/mentor/dashboard', builder: (context, state) => const MentorDashboardScreen()),
      GoRoute(path: '/mentor/analytics', builder: (context, state) => const EmployeeAnalyticsScreen()),
      GoRoute(path: '/mentor/qbank', builder: (context, state) => const QuestionBankEditorScreen()),
      GoRoute(
        path: '/mentor/add-question/details',
        builder: (context, state) {
          final existing = state.extra as Map<String, dynamic>?;
          return AddQuestionDetailsScreen(existingQuestion: existing);
        },
      ),
      GoRoute(
        path: '/mentor/add-question/difficulty',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return AddQuestionDifficultyScreen(questionData: data);
        },
      ),
      GoRoute(
        path: '/mentor/add-question/success',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return AddQuestionSuccessScreen(questionData: data);
        },
      ),

      // Settings & Notifications
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationCenterScreen()),
      GoRoute(path: '/settings/notifications', builder: (context, state) => const NotificationSettingsScreen()),
      GoRoute(path: '/notifications/export', builder: (context, state) => const PushNotificationExportScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
    ],
  );
});
