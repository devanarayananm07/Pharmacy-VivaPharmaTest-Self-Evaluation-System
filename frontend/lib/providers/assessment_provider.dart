import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class AssessmentState {
  final bool isLoading;
  final String? error;
  final List<dynamic> questions;
  final int currentIndex;
  final Map<int, Map<String, dynamic>> answers;
  final String? attemptId;
  final String difficulty; // Easy, Medium, Hard
  final bool isSubmitted;
  final double score;
  final Map<int, List<String>> hardModeOptions; // Stores generated options for Hard Mode select field
  final Map<int, List<Map<String, dynamic>>> mcqOptions; // Stores generated 4-option MCQs per question index
  final Map<int, Map<String, dynamic>> selectedAnswers;

  AssessmentState({
    this.isLoading = false,
    this.error,
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.attemptId,
    this.difficulty = 'Easy',
    this.isSubmitted = false,
    this.score = 0.0,
    this.hardModeOptions = const {},
    this.mcqOptions = const {},
    this.selectedAnswers = const {},
  });

  AssessmentState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? questions,
    int? currentIndex,
    Map<int, Map<String, dynamic>>? answers,
    String? attemptId,
    bool clearAttemptId = false,
    String? difficulty,
    bool? isSubmitted,
    double? score,
    Map<int, List<String>>? hardModeOptions,
    Map<int, List<Map<String, dynamic>>>? mcqOptions,
    Map<int, Map<String, dynamic>>? selectedAnswers,
  }) {
    return AssessmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      attemptId: clearAttemptId ? null : (attemptId ?? this.attemptId),
      difficulty: difficulty ?? this.difficulty,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      score: score ?? this.score,
      hardModeOptions: hardModeOptions ?? this.hardModeOptions,
      mcqOptions: mcqOptions ?? this.mcqOptions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class AssessmentNotifier extends Notifier<AssessmentState> {
  @override
  AssessmentState build() {
    return AssessmentState();
  }

  String _extractStrength(String gsp) {
    final start = gsp.indexOf('(');
    final end = gsp.indexOf(')');
    if (start != -1 && end != -1 && end > start + 1) {
      return gsp.substring(start + 1, end).trim();
    }
    return '';
  }

  String _extractDosage(String gsp) {
    final end = gsp.indexOf(')');
    if (end != -1 && end + 1 < gsp.length) {
      return gsp.substring(end + 1).trim();
    }
    return gsp.trim();
  }

  Map<String, dynamic> _buildMcqOptionMap(dynamic D) {
    final gsp = D['gsp']?.toString() ?? '';
    final strength = _extractStrength(gsp);
    final dosageForm = _extractDosage(gsp);
    final ved = D['ved']?.toString().toUpperCase() ?? 'E';

    String contra = 'General monitoring recommended';
    if (ved == 'V') {
      contra = 'NSAID risk in Stage 3 CKD';
    } else if (ved == 'E') {
      contra = 'Standard dosage adjustment required in CKD';
    }

    return {
      'brand_name': D['drug_name'] ?? '',
      'strength': strength,
      'dosage_form': dosageForm,
      'schedule': D['schedule'] ?? 'OTC',
      'indication': D['indication'] ?? '',
      'company': D['company'] ?? '',
      'generic_name': D['generic_name'] ?? '',
      'contraindication': contra,
      'rationale': 'Clinical rationale for prescribing ${D['generic_name'] ?? 'drug'} based on indications.',
      'dosage': 'Standard dose based on patient profile.',
      'drug_name': D['drug_name'] ?? '',
      'gsp': gsp,
    };
  }

  // 1. Initialize Assessment (Start Viva)
  Future<bool> startAssessment({
    required int count,
    required String difficulty,
    String? store,
    String? department,
    String? days,
  }) async {
    state = AssessmentState(isLoading: true, difficulty: difficulty);
    try {
      final apiService = ref.read(apiServiceProvider);
      final auth = ref.read(authProvider);
      final employeeId = auth.employeeId ?? 'Unknown';
      
      // Load questions matching constraints
      final rawQuestions = await apiService.getQuestions(
        store: store,
        speciality: department,
        days: days,
      );

      if (rawQuestions.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'No questions found for the selected filters.');
        return false;
      }

      // Shuffle and take requested count
      final shuffled = List.from(rawQuestions)..shuffle();
      final selectedQuestions = shuffled.take(count).toList();

      // Ensure Easy mode doesn't repeat generic names
      if (difficulty == 'Easy') {
        final seenGenerics = <String>{};
        final uniqueQuestions = <dynamic>[];
        for (var q in shuffled) {
          final gName = q['generic_name'].toString().toUpperCase();
          if (!seenGenerics.contains(gName)) {
            seenGenerics.add(gName);
            uniqueQuestions.add(q);
          }
          if (uniqueQuestions.length == count) break;
        }
        // Fallback if unique count is less than requested
        if (uniqueQuestions.length < count) {
          uniqueQuestions.addAll(shuffled.where((q) => !uniqueQuestions.contains(q)).take(count - uniqueQuestions.length));
        }
        selectedQuestions.clear();
        selectedQuestions.addAll(uniqueQuestions);
      }

      // Generate Attempt ID
      final random = Random();
      final attemptHash = List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join();
      final attemptId = 'ATT$attemptHash';

      // Call API to register attempt
      final formattedDate = DateTime.now().toIso8601String().split('T')[0];
      final attemptBody = {
        "attempt_id": attemptId,
        "employee_id": employeeId,
        "store": store ?? 'Pharmacy Store',
        "exam_day": days ?? 'Day 1',
        "date": formattedDate,
        "status": "Started",
        "score": 0,
        "max_score": 100,
        "percent": 0,
        "passed": 0,
        "started_at": DateTime.now().toString().substring(0, 19),
        "submitted_at": "",
        "section_scores": "{}"
      };
      
      await apiService.createAttempt(attemptBody);

      // Pre-generate Hard Mode options if difficulty is Hard
      final Map<int, List<String>> hardOptions = {};
      if (difficulty == 'Hard') {
        for (int i = 0; i < selectedQuestions.length; i++) {
          final q = selectedQuestions[i];
          final ved = q['ved'].toString().toUpperCase();
          
          List<String> options = [];
          if (ved == 'V') {
            options = ["NSAID risk in Stage 3 CKD", "High risk in Cardiac Impairment", "Age-related Hepatic Clearance"];
          } else if (ved == 'E') {
            options = ["Standard dosage adjustment required in CKD", "Severe GI ulceration risk", "Hypersensitivity / Anaphylaxis risk"];
          } else {
            options = ["General monitoring recommended", "Potential drowsiness warning", "Avoid alcohol co-administration"];
          }
          hardOptions[i] = options;
        }
      }

      // Generate MCQ Options for each selected question
      final Map<int, List<Map<String, dynamic>>> generatedMcqOptions = {};
      for (int i = 0; i < selectedQuestions.length; i++) {
        final q = selectedQuestions[i];
        final correctOption = _buildMcqOptionMap(q);
        
        // Find distractors
        final distractors = <dynamic>[];
        for (var o in rawQuestions) {
          if (o['generic_name'].toString().toLowerCase() != q['generic_name'].toString().toLowerCase() &&
              o['drug_name'].toString().toLowerCase() != q['drug_name'].toString().toLowerCase()) {
            distractors.add(o);
          }
        }
        
        // Filter out duplicates (based on brand_name)
        final uniqueDistractors = <Map<String, dynamic>>[];
        final seenBrands = <String>{correctOption['brand_name'].toString().toLowerCase()};
        for (var d in distractors) {
          final brand = d['drug_name'].toString().toLowerCase();
          if (!seenBrands.contains(brand)) {
            seenBrands.add(brand);
            uniqueDistractors.add(_buildMcqOptionMap(d));
          }
        }
        
        uniqueDistractors.shuffle();
        final selectedDistractors = uniqueDistractors.take(3).toList();
        
        // Ensure exactly 3 distractors
        while (selectedDistractors.length < 3) {
          final dummyIndex = selectedDistractors.length + 1;
          selectedDistractors.add({
            'brand_name': 'Sample Brand $dummyIndex',
            'strength': '50 mg',
            'dosage_form': 'Tablet',
            'schedule': 'OTC',
            'indication': 'to manage general symptoms',
            'company': 'Pharma Ltd',
            'generic_name': 'GENERIC',
            'contraindication': 'General monitoring recommended',
            'rationale': 'Clinical rationale for prescribing drug.',
            'dosage': 'Standard dose.',
            'drug_name': 'Sample Brand $dummyIndex',
            'gsp': 'GENERIC(50 mg)Tablet',
          });
        }
        
        final options = [correctOption, ...selectedDistractors]..shuffle();
        generatedMcqOptions[i] = options;
      }

      state = state.copyWith(
        isLoading: false,
        questions: selectedQuestions,
        currentIndex: 0,
        answers: {},
        selectedAnswers: {},
        attemptId: attemptId,
        hardModeOptions: hardOptions,
        mcqOptions: generatedMcqOptions,
      );

      // Save active session locally to allow resumes
      final prefs = await SharedPreferences.getInstance();
      final savedIds = await _getSavedAttemptIds(prefs);
      if (!savedIds.contains(attemptId)) {
        savedIds.add(attemptId);
        await _saveSavedAttemptIds(prefs, savedIds);
      }

      await prefs.setString('active_viva_attempt_id', attemptId);
      await prefs.setString('active_exam_${attemptId}_difficulty', difficulty);
      await prefs.setString('active_exam_${attemptId}_questions', jsonEncode(selectedQuestions));
      await prefs.setString('active_exam_${attemptId}_answers', jsonEncode({}));
      await prefs.setString('active_exam_${attemptId}_mcq_options', jsonEncode(
        generatedMcqOptions.map((key, value) => MapEntry(key.toString(), value))
      ));
      await prefs.setString('active_exam_${attemptId}_store', store ?? 'All');
      await prefs.setString('active_exam_${attemptId}_days', days ?? 'All');
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // 2. Select Answer (Temporary selection before Save)
  void selectAnswer(Map<String, dynamic> opt) {
    if (state.answers.containsKey(state.currentIndex)) return;

    final updatedSelected = Map<int, Map<String, dynamic>>.from(state.selectedAnswers);
    updatedSelected[state.currentIndex] = opt;
    state = state.copyWith(selectedAnswers: updatedSelected);
  }

  // Save current temporary selection to locked answers
  bool saveCurrentAnswer() {
    final selected = state.selectedAnswers[state.currentIndex];
    if (selected == null) return false;

    final updatedAnswers = Map<int, Map<String, dynamic>>.from(state.answers);
    updatedAnswers[state.currentIndex] = selected;
    state = state.copyWith(answers: updatedAnswers);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('active_exam_${state.attemptId}_answers', jsonEncode(
        updatedAnswers.map((key, value) => MapEntry(key.toString(), value))
      ));
    });
    return true;
  }

  // Save Answer directly (for tests & backward compatibility)
  void saveAnswer(Map<String, dynamic> currentAnswers) {
    final updatedSelected = Map<int, Map<String, dynamic>>.from(state.selectedAnswers);
    updatedSelected[state.currentIndex] = currentAnswers;

    final updatedAnswers = Map<int, Map<String, dynamic>>.from(state.answers);
    updatedAnswers[state.currentIndex] = currentAnswers;

    state = state.copyWith(
      selectedAnswers: updatedSelected,
      answers: updatedAnswers,
    );

    // Save to SharedPreferences for resilience
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('active_exam_${state.attemptId}_answers', jsonEncode(
        updatedAnswers.map((key, value) => MapEntry(key.toString(), value))
      ));
    });
  }

  // Restart/Retest the entire exam
  void restartExam() {
    final random = Random();
    final attemptHash = List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join();
    final attemptId = 'ATT$attemptHash';

    state = AssessmentState(
      attemptId: attemptId,
      difficulty: state.difficulty,
      questions: state.questions,
      hardModeOptions: state.hardModeOptions,
      mcqOptions: state.mcqOptions,
    );

    SharedPreferences.getInstance().then((prefs) async {
      final listStr = prefs.getString('active_exam_attempt_ids');
      List<String> savedIds = [];
      if (listStr != null) {
        try {
          savedIds = (jsonDecode(listStr) as List).map((e) => e.toString()).toList();
        } catch (_) {}
      }
      if (!savedIds.contains(attemptId)) {
        savedIds.add(attemptId);
        await prefs.setString('active_exam_attempt_ids', jsonEncode(savedIds));
      }

      await prefs.setString('active_viva_attempt_id', attemptId);
      await prefs.setString('active_exam_${attemptId}_difficulty', state.difficulty);
      await prefs.setString('active_exam_${attemptId}_questions', jsonEncode(state.questions));
      await prefs.setString('active_exam_${attemptId}_answers', jsonEncode({}));
      await prefs.setString('active_exam_${attemptId}_mcq_options', jsonEncode(
        state.mcqOptions.map((key, value) => MapEntry(key.toString(), value))
      ));
    });
  }

  // Resets the assessment provider state to clean default values (which unlocks study screens)
  void resetState() {
    state = AssessmentState();
  }

  // 3. Clear Current Answers (Retest)
  void retestCurrentQuestion() {
    final updatedAnswers = Map<int, Map<String, dynamic>>.from(state.answers);
    updatedAnswers.remove(state.currentIndex);

    final updatedSelected = Map<int, Map<String, dynamic>>.from(state.selectedAnswers);
    updatedSelected.remove(state.currentIndex);

    state = state.copyWith(
      answers: updatedAnswers,
      selectedAnswers: updatedSelected,
    );
  }

  // 4. Navigation
  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void prevQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  Future<List<String>> _getSavedAttemptIds(SharedPreferences prefs) async {
    final listStr = prefs.getString('active_exam_attempt_ids');
    if (listStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(listStr);
        return decoded.map((e) => e.toString()).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Future<void> _saveSavedAttemptIds(SharedPreferences prefs, List<String> ids) async {
    await prefs.setString('active_exam_attempt_ids', jsonEncode(ids));
  }

  // 5. Resume Viva Session (from Local Storage)
  Future<bool> tryResumeViva({String? targetAttemptId}) async {
    final prefs = await SharedPreferences.getInstance();
    final attemptId = targetAttemptId ?? prefs.getString('active_viva_attempt_id');
    if (attemptId == null) return false;

    final difficulty = prefs.getString('active_exam_${attemptId}_difficulty');
    final questionsStr = prefs.getString('active_exam_${attemptId}_questions');
    final answersStr = prefs.getString('active_exam_${attemptId}_answers');
    final mcqOptionsStr = prefs.getString('active_exam_${attemptId}_mcq_options');

    if (difficulty != null && questionsStr != null) {
      try {
        final List<dynamic> loadedQuestions = jsonDecode(questionsStr);
        Map<int, Map<String, dynamic>> loadedAnswers = {};
        if (answersStr != null) {
          final decoded = jsonDecode(answersStr) as Map;
          decoded.forEach((key, value) {
            loadedAnswers[int.parse(key)] = Map<String, dynamic>.from(value);
          });
        }

        Map<int, List<Map<String, dynamic>>> loadedMcqOptions = {};
        if (mcqOptionsStr != null) {
          final decoded = jsonDecode(mcqOptionsStr) as Map;
          decoded.forEach((key, value) {
            loadedMcqOptions[int.parse(key)] = (value as List)
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          });
        }

        // Regen Hard Mode options if necessary
        final Map<int, List<String>> hardOptions = {};
        if (difficulty == 'Hard') {
          for (int i = 0; i < loadedQuestions.length; i++) {
            final q = loadedQuestions[i];
            final ved = q['ved'].toString().toUpperCase();
            List<String> options = [];
            if (ved == 'V') {
              options = ["NSAID risk in Stage 3 CKD", "High risk in Cardiac Impairment", "Age-related Hepatic Clearance"];
            } else if (ved == 'E') {
              options = ["Standard dosage adjustment required in CKD", "Severe GI ulceration risk", "Hypersensitivity / Anaphylaxis risk"];
            } else {
              options = ["General monitoring recommended", "Potential drowsiness warning", "Avoid alcohol co-administration"];
            }
            hardOptions[i] = options;
          }
        }

        // Fallback option regeneration if mcqOptions is missing or failed to parse
        if (loadedMcqOptions.isEmpty) {
          for (int i = 0; i < loadedQuestions.length; i++) {
            final q = loadedQuestions[i];
            final correctOption = _buildMcqOptionMap(q);
            final List<Map<String, dynamic>> options = [correctOption];
            
            // Add 3 dummy distractors for fallback simplicity
            for (int dIndex = 1; dIndex <= 3; dIndex++) {
              options.add({
                'brand_name': 'Sample Brand $dIndex',
                'strength': '50 mg',
                'dosage_form': 'Tablet',
                'schedule': 'OTC',
                'indication': 'to manage general symptoms',
                'company': 'Pharma Ltd',
                'generic_name': 'GENERIC',
                'contraindication': 'General monitoring recommended',
                'rationale': 'Clinical rationale for prescribing drug.',
                'dosage': 'Standard dose.',
                'drug_name': 'Sample Brand $dIndex',
                'gsp': 'GENERIC(50 mg)Tablet',
              });
            }
            options.shuffle();
            loadedMcqOptions[i] = options;
          }
        }

        await prefs.setString('active_viva_attempt_id', attemptId);

        state = AssessmentState(
          questions: loadedQuestions,
          currentIndex: 0,
          answers: loadedAnswers,
          selectedAnswers: Map<int, Map<String, dynamic>>.from(loadedAnswers),
          attemptId: attemptId,
          difficulty: difficulty,
          hardModeOptions: hardOptions,
          mcqOptions: loadedMcqOptions,
        );
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  // Get list of saved assessments
  Future<List<Map<String, String>>> getSavedAssessments() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = await _getSavedAttemptIds(prefs);
    
    final List<Map<String, String>> result = [];
    for (var id in savedIds) {
      final store = prefs.getString('active_exam_${id}_store') ?? 'All';
      final days = prefs.getString('active_exam_${id}_days') ?? 'All';
      final diff = prefs.getString('active_exam_${id}_difficulty') ?? 'Easy';
      
      int totalQuestions = 0;
      final qStr = prefs.getString('active_exam_${id}_questions');
      if (qStr != null) {
        try {
          final List<dynamic> qList = jsonDecode(qStr);
          totalQuestions = qList.length;
        } catch (_) {}
      }

      int attendedQuestions = 0;
      final aStr = prefs.getString('active_exam_${id}_answers');
      if (aStr != null) {
        try {
          final Map<String, dynamic> aMap = jsonDecode(aStr);
          attendedQuestions = aMap.length;
        } catch (_) {}
      }

      result.add({
        'attemptId': id,
        'store': store,
        'days': days,
        'difficulty': diff,
        'totalQuestions': totalQuestions.toString(),
        'attendedQuestions': attendedQuestions.toString(),
      });
    }
    return result;
  }

  // Clear specific session
  Future<void> clearSpecificSession(String attemptId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove from saved attempts list
    final savedIds = await _getSavedAttemptIds(prefs);
    savedIds.remove(attemptId);
    await _saveSavedAttemptIds(prefs, savedIds);

    // Remove details
    await prefs.remove('active_exam_${attemptId}_difficulty');
    await prefs.remove('active_exam_${attemptId}_questions');
    await prefs.remove('active_exam_${attemptId}_answers');
    await prefs.remove('active_exam_${attemptId}_mcq_options');
    await prefs.remove('active_exam_${attemptId}_store');
    await prefs.remove('active_exam_${attemptId}_days');

    final activeId = prefs.getString('active_viva_attempt_id');
    if (activeId == attemptId) {
      await prefs.remove('active_viva_attempt_id');
    }
  }

  // 6. Clear Local Session (Save & Quit or Abort)
  Future<void> clearLocalSession() async {
    final attemptId = state.attemptId;
    if (attemptId == null) return;
    await clearSpecificSession(attemptId);
  }

  // 7. Grade Active Session & Submit
  Future<double> submitAssessment() async {
    state = state.copyWith(isLoading: true);
    double totalEarnedMarks = 0.0;
    final int questionCount = state.questions.length;

    // Grades each question out of 100 marks
    for (int i = 0; i < questionCount; i++) {
      final question = state.questions[i];
      final userAns = state.answers[i] ?? {};
      double questionMarks = 0.0;

      if (state.difficulty == 'Easy') {
        // Easy Mode: 5 fields, 20 marks each
        // 1. Brand Name
        final correctBrand = question['drug_name'].toString().toLowerCase().trim();
        final userBrand = userAns['brand_name'].toString().toLowerCase().trim();
        if (userBrand.isNotEmpty && correctBrand.contains(userBrand)) {
          questionMarks += 20;
        }

        // 2. Strength & Dosage (gsp contains both, e.g. "ENALAPRIL(5 mg)Tablet")
        final correctGsp = question['gsp'].toString().toLowerCase();
        final userStrength = userAns['strength'].toString().toLowerCase().trim();
        final userDosage = userAns['dosage_form'].toString().toLowerCase().trim();
        if (userStrength.isNotEmpty && correctGsp.contains(userStrength)) {
          questionMarks += 10;
        }
        if (userDosage.isNotEmpty && correctGsp.contains(userDosage)) {
          questionMarks += 10;
        }

        // 3. Schedule
        final correctSchedule = question['schedule'].toString().toLowerCase().trim();
        final userSchedule = userAns['schedule'].toString().toLowerCase().trim();
        if (userSchedule.isNotEmpty && (correctSchedule == userSchedule || (correctSchedule == 'otc' && userSchedule == 'over the counter (otc)'))) {
          questionMarks += 20;
        }

        // 4. Indication
        final correctIndication = question['indication'].toString().toLowerCase().trim();
        final userIndication = userAns['indication'].toString().toLowerCase().trim();
        if (userIndication.isNotEmpty && (correctIndication.contains(userIndication) || userIndication.contains(correctIndication))) {
          questionMarks += 20;
        }

        // 5. Company Name
        final correctCompany = question['company'].toString().toLowerCase().trim();
        final userCompany = userAns['company'].toString().toLowerCase().trim();
        if (userCompany.isNotEmpty && (correctCompany.contains(userCompany) || userCompany.contains(correctCompany))) {
          questionMarks += 20;
        }

      } else if (state.difficulty == 'Medium') {
        // Medium Mode: 4 fields, 25 marks each
        // 1. Generic Name
        final correctGeneric = question['generic_name'].toString().toLowerCase().trim();
        final userGeneric = userAns['generic_name'].toString().toLowerCase().trim();
        if (userGeneric.isNotEmpty && correctGeneric.contains(userGeneric)) {
          questionMarks += 25;
        }

        // 2. Associated Brand Name
        final correctBrand = question['drug_name'].toString().toLowerCase().trim();
        final userBrand = userAns['brand_name'].toString().toLowerCase().trim();
        if (userBrand.isNotEmpty && correctBrand.contains(userBrand)) {
          questionMarks += 25;
        }

        // 3. Manufacturing Company
        final correctCompany = question['company'].toString().toLowerCase().trim();
        final userCompany = userAns['company'].toString().toLowerCase().trim();
        if (userCompany.isNotEmpty && (correctCompany.contains(userCompany) || userCompany.contains(correctCompany))) {
          questionMarks += 25;
        }

        // 4. Schedule Category
        final correctSchedule = question['schedule'].toString().toLowerCase().trim();
        final userSchedule = userAns['schedule'].toString().toLowerCase().trim();
        if (userSchedule.isNotEmpty && (correctSchedule == userSchedule || (correctSchedule == 'otc' && userSchedule == 'over the counter (otc)'))) {
          questionMarks += 25;
        }

      } else {
        // Hard Mode: Scenario based, 4 fields, 25 marks each
        // 1. Primary Contraindication
        final userContra = userAns['contraindication'].toString().toLowerCase().trim();
        // Easy match for simulated options
        if (userContra.isNotEmpty && (userContra.contains("nsaid") || userContra.contains("standard") || userContra.contains("monitoring"))) {
          questionMarks += 25;
        }

        // 2. Recommended Generic
        final correctGeneric = question['generic_name'].toString().toLowerCase().trim();
        final userGeneric = userAns['generic_name'].toString().toLowerCase().trim();
        if (userGeneric.isNotEmpty && correctGeneric.contains(userGeneric)) {
          questionMarks += 25;
        }

        // 3. Clinical Rationale
        final userRationale = userAns['rationale'].toString().trim();
        if (userRationale.length > 5) {
          questionMarks += 25; // Score based on text present
        }

        // 4. Dosage Adjustment
        final userDosage = userAns['dosage'].toString().trim();
        if (userDosage.isNotEmpty) {
          questionMarks += 25;
        }
      }

      totalEarnedMarks += questionMarks;
    }

    final double averageScore = questionCount > 0 ? totalEarnedMarks / questionCount : 0.0;
    final passed = averageScore >= 70 ? 1 : 0; // 70% passing threshold
    
    try {
      final apiService = ref.read(apiServiceProvider);
      final auth = ref.read(authProvider);
      final employeeId = auth.employeeId ?? 'Unknown';

      // Submit completed attempt
      final attemptBody = {
        "attempt_id": state.attemptId,
        "employee_id": employeeId,
        "store": state.questions.first['store'] ?? 'Pharmacy Store',
        "exam_day": state.questions.first['days'] ?? 'Day 1',
        "date": DateTime.now().toIso8601String().split('T')[0],
        "status": "Completed",
        "score": averageScore.round(),
        "max_score": 100,
        "percent": double.parse(averageScore.toStringAsFixed(1)),
        "passed": passed,
        "started_at": DateTime.now().subtract(const Duration(minutes: 20)).toString().substring(0, 19),
        "submitted_at": DateTime.now().toString().substring(0, 19),
        "section_scores": "{\"Accuracy\": ${averageScore.round()}}"
      };

      await apiService.createAttempt(attemptBody);
      await clearLocalSession();

      state = state.copyWith(
        isLoading: false,
        isSubmitted: true,
        score: averageScore,
        clearAttemptId: true, // Reset attemptId immediately upon success
      );
      
      return averageScore;
    } catch (e) {
      // Even if network logging fails, local session is cleared and state attemptId is reset
      await clearLocalSession();
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSubmitted: true,
        score: averageScore,
        clearAttemptId: true, // Reset attemptId immediately upon failure to unlock study screen
      );
      return averageScore;
    }
  }
}

final assessmentProvider = NotifierProvider<AssessmentNotifier, AssessmentState>(() {
  return AssessmentNotifier();
});
