import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmaq/providers/assessment_provider.dart';
import 'package:pharmaq/services/api_service.dart';

// Mock Api Service for testing
class MockApiService extends ApiService {
  @override
  Future<List<dynamic>> getQuestions({String? store, String? speciality, String? days, int page = 1, int pageSize = 50, String? search}) async {
    return [
      {
        "id": "100",
        "generic_name": "ASPIRIN",
        "drug_name": "Ecotrin 150mg",
        "gsp": "ASPIRIN(150 mg)Tablet",
        "schedule": "OTC",
        "indication": "prevent blood clots",
        "company": "Bayer",
        "speciality": "Cardiology",
        "ved": "E",
        "abc": "B",
        "sku": "Y"
      }
    ];
  }

  @override
  Future<Map<String, dynamic>> createAttempt(Map<String, dynamic> attempt) async {
    return attempt;
  }
}

void main() {
  // Initialize test binding
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PharmaQ Grading Logic Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockApiService()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Easy Mode Grading - Perfect Score', () async {
      final notifier = container.read(assessmentProvider.notifier);
      
      // Start assessment
      final success = await notifier.startAssessment(count: 1, difficulty: 'Easy');
      expect(success, isTrue);

      final state = container.read(assessmentProvider);
      expect(state.questions.length, 1);
      expect(state.questions.first['generic_name'], 'ASPIRIN');

      // Provide correct answers
      notifier.saveAnswer({
        'brand_name': 'Ecotrin 150mg',
        'strength': '150 mg',
        'dosage_form': 'Tablet',
        'schedule': 'OTC',
        'indication': 'prevent blood clots',
        'company': 'Bayer',
      });

      // Grade
      final score = await notifier.submitAssessment();
      expect(score, 100.0);
    });

    test('Easy Mode Grading - Partial Score', () async {
      final notifier = container.read(assessmentProvider.notifier);
      final success = await notifier.startAssessment(count: 1, difficulty: 'Easy');
      expect(success, isTrue);

      // Provide partially correct answers
      notifier.saveAnswer({
        'brand_name': 'Incorrect Brand', // 0 marks
        'strength': '150 mg', // 10 marks
        'dosage_form': 'Tablet', // 10 marks
        'schedule': 'OTC', // 20 marks
        'indication': 'prevent blood clots', // 20 marks
        'company': 'Incorrect Company', // 0 marks
      });

      final score = await notifier.submitAssessment();
      expect(score, 60.0); // 10 + 10 + 20 + 20 = 60
    });

    test('Medium Mode Grading - Perfect Score', () async {
      final notifier = container.read(assessmentProvider.notifier);
      final success = await notifier.startAssessment(count: 1, difficulty: 'Medium');
      expect(success, isTrue);

      // Provide correct answers
      notifier.saveAnswer({
        'generic_name': 'Aspirin',
        'brand_name': 'Ecotrin 150mg',
        'company': 'Bayer',
        'schedule': 'OTC',
      });

      final score = await notifier.submitAssessment();
      expect(score, 100.0);
    });

    test('Hard Mode Grading - Perfect Score', () async {
      final notifier = container.read(assessmentProvider.notifier);
      final success = await notifier.startAssessment(count: 1, difficulty: 'Hard');
      expect(success, isTrue);

      // Provide correct answers
      notifier.saveAnswer({
        'contraindication': 'Standard dosage adjustment required in CKD', // matches Mock options for 'E'
        'generic_name': 'Aspirin',
        'rationale': 'This is an explanation that is long enough.',
        'dosage': '100mg daily',
      });

      final score = await notifier.submitAssessment();
      expect(score, 100.0);
    });
  });
}
