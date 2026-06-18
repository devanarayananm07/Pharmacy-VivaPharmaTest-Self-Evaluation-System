import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmaq/providers/score_provider.dart';
import 'package:pharmaq/providers/auth_provider.dart';
import 'package:pharmaq/services/api_service.dart';

class MockScoreApiService extends ApiService {
  final List<dynamic> _attempts;
  MockScoreApiService(this._attempts);

  @override
  Future<List<dynamic>> getAttempts({String? employeeId}) async {
    return _attempts;
  }

  @override
  Future<List<dynamic>> getEmployees() async {
    return [
      {
        'emp_id': 'EMP001',
        'name1': 'Employee One',
        'designation': 'Pharmacist',
      },
      {
        'emp_id': 'EMP002',
        'name1': 'Employee Two',
        'designation': 'Pharmacist',
      },
      {
        'emp_id': 'EMP003',
        'name1': 'Mentor Three',
        'designation': 'Clinical Mentor',
      }
    ];
  }

  @override
  Future<List<dynamic>> getQuestions({String? store, String? speciality, String? days, int page = 1, int pageSize = 50, String? search}) async {
    return [];
  }
}

class MockAuthNotifier extends AuthNotifier {
  final AuthState mockState;
  MockAuthNotifier(this.mockState);

  @override
  AuthState build() {
    return mockState;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PharmaQ Score History Provider Tests', () {
    late List<dynamic> testAttempts;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      testAttempts = [
        {
          'id': '1',
          'employee_id': 'EMP001',
          'store': 'Store A',
          'exam_day': 'Day 1',
          'status': 'Completed',
          'percent': 80.0,
          'passed': 1,
          'date': '2026-06-10 10:00:00',
        },
        {
          'id': '2',
          'employee_id': 'EMP001',
          'store': 'Store B',
          'exam_day': 'Day 2',
          'status': 'Completed',
          'percent': 60.0,
          'passed': 0,
          'date': '2026-06-11 11:00:00',
        },
        {
          'id': '3',
          'employee_id': 'EMP002',
          'store': 'Store A',
          'exam_day': 'Day 1',
          'status': 'Completed',
          'percent': 90.0,
          'passed': 1,
          'date': '2026-06-12 12:00:00',
        },
        {
          'id': '4',
          'employee_id': 'EMP003',
          'store': 'Store A',
          'exam_day': 'Day 1',
          'status': 'Completed',
          'percent': 95.0,
          'passed': 1,
          'date': '2026-06-12 13:00:00',
        },
        {
          'id': '5',
          'employee_id': 'EMP001',
          'store': 'Store A',
          'exam_day': 'Day 2',
          'status': 'In-Progress', // Should be ignored in stats
          'percent': 50.0,
          'passed': 0,
          'date': '2026-06-12 09:00:00',
        }
      ];
    });

    test('Employee View - Overall Insights (All, All)', () async {
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockScoreApiService(testAttempts)),
          authProvider.overrideWith(() => MockAuthNotifier(
            AuthState.authenticated(
              employeeId: 'EMP001',
              employeeName: 'Employee One',
              role: 'Employee',
              designation: 'Pharmacist',
              workArea: 'Store A',
            ),
          )),
        ],
      );

      // Query overall
      final stats = await container.read(scoreHistoryProvider(
        ScoreFilters(store: 'All', days: 'All', viewMode: 'self'),
      ).future);

      // EMP001 has two completed attempts: 80% (passed) and 60% (failed)
      expect(stats.totalAttempts, 2);
      expect(stats.passedAttempts, 1);
      expect(stats.avgScore, 70.0); // (80 + 60) / 2
      expect(stats.successRate, 50.0); // 1 / 2 * 100
      expect(stats.trends.length, 2);
      // Sorted chronologically in trend (V1=80% on 2026-06-10, V2=60% on 2026-06-11)
      expect(stats.trends[0], 80.0);
      expect(stats.trends[1], 60.0);

      container.dispose();
    });

    test('Employee View - Filtered (Store A, Day 1)', () async {
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockScoreApiService(testAttempts)),
          authProvider.overrideWith(() => MockAuthNotifier(
            AuthState.authenticated(
              employeeId: 'EMP001',
              employeeName: 'Employee One',
              role: 'Employee',
              designation: 'Pharmacist',
              workArea: 'Store A',
            ),
          )),
        ],
      );

      final stats = await container.read(scoreHistoryProvider(
        ScoreFilters(store: 'Store A', days: 'Day 1', viewMode: 'self'),
      ).future);

      // Only first attempt matches: 80% (passed)
      expect(stats.totalAttempts, 1);
      expect(stats.passedAttempts, 1);
      expect(stats.avgScore, 80.0);
      expect(stats.successRate, 100.0);
      expect(stats.trends, [80.0]);

      container.dispose();
    });

    test('Mentor View - Self Scores (viewMode = self)', () async {
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockScoreApiService(testAttempts)),
          authProvider.overrideWith(() => MockAuthNotifier(
            AuthState.authenticated(
              employeeId: 'EMP001',
              employeeName: 'Mentor One',
              role: 'Mentor',
              designation: 'Clinical Mentor',
              workArea: 'Store A',
            ),
          )),
        ],
      );

      final stats = await container.read(scoreHistoryProvider(
        ScoreFilters(store: 'All', days: 'All', viewMode: 'self'),
      ).future);

      // Mentor (EMP001) has two completed attempts
      expect(stats.totalAttempts, 2);
      expect(stats.attempts[0]['employee_id'], 'EMP001');

      container.dispose();
    });

    test('Mentor View - Employee Scores (viewMode = employees)', () async {
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockScoreApiService(testAttempts)),
          authProvider.overrideWith(() => MockAuthNotifier(
            AuthState.authenticated(
              employeeId: 'EMP001',
              employeeName: 'Mentor One',
              role: 'Mentor',
              designation: 'Clinical Mentor',
              workArea: 'Store A',
            ),
          )),
        ],
      );

      final stats = await container.read(scoreHistoryProvider(
        ScoreFilters(store: 'All', days: 'All', viewMode: 'employees'),
      ).future);

      // Only EMP002 attempt matches (since EMP001 is filtered out as self)
      expect(stats.totalAttempts, 1);
      expect(stats.attempts[0]['employee_id'], 'EMP002');
      expect(stats.attempts[0]['percent'], 90.0);

      container.dispose();
    });

    test('Mentor View - Mentor Scores (viewMode = mentors)', () async {
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockScoreApiService(testAttempts)),
          authProvider.overrideWith(() => MockAuthNotifier(
            AuthState.authenticated(
              employeeId: 'EMP001',
              employeeName: 'Mentor One',
              role: 'Mentor',
              designation: 'Clinical Mentor',
              workArea: 'Store A',
            ),
          )),
        ],
      );

      final stats = await container.read(scoreHistoryProvider(
        ScoreFilters(store: 'All', days: 'All', viewMode: 'mentors'),
      ).future);

      // Only EMP003 attempt matches (since it is a mentor attempt and EMP001 is filtered out as self)
      expect(stats.totalAttempts, 1);
      expect(stats.attempts[0]['employee_id'], 'EMP003');
      expect(stats.attempts[0]['percent'], 95.0);

      container.dispose();
    });
  });
}
