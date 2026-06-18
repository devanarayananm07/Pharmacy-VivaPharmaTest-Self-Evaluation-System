import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/top_app_bar.dart';
import '../components/pharmaq_card.dart';
import '../theme/obsidian_theme.dart';
import '../providers/assessment_provider.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  void _handleNext(AssessmentState state) {
    if (state.currentIndex == state.questions.length - 1) {
      if (state.answers.length < state.questions.length) {
        _showUnsavedQuestionsAlert();
      } else {
        _showSubmissionConfirmation();
      }
    } else {
      ref.read(assessmentProvider.notifier).nextQuestion();
    }
  }

  void _handleSaveAndQuit() async {
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exam progress saved. You can resume later.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleQuitDirectly() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ObsidianTheme.surfaceContainer,
        title: const Text('Exit Exam Assessment?', style: TextStyle(color: ObsidianTheme.onSurface, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to quit? Unsaved changes will be lost.', style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final router = GoRouter.of(context);
              await ref.read(assessmentProvider.notifier).clearLocalSession();
              router.pop(); // Return to dashboard
            },
            style: ElevatedButton.styleFrom(backgroundColor: ObsidianTheme.error),
            child: const Text('Quit without Saving', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUnsavedQuestionsAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ObsidianTheme.surfaceContainer,
        title: const Text('Unsaved Questions', style: TextStyle(color: ObsidianTheme.onSurface, fontWeight: FontWeight.bold)),
        content: const Text(
          'You must save the answers for all questions before you can submit the exam. Please review your questions and save your answers.',
          style: TextStyle(color: ObsidianTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSubmissionConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ObsidianTheme.surfaceContainer,
        title: const Text('Submit Exam?', style: TextStyle(color: ObsidianTheme.onSurface, fontWeight: FontWeight.bold)),
        content: const Text('You have answered all questions. Submit now to review your evaluation report.', style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Review Answers'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final score = await ref.read(assessmentProvider.notifier).submitAssessment();
              if (mounted) {
                _showResultScreen(score);
              }
            },
            child: const Text('Submit Exam', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showResultScreen(double score) {
    final isPerfect = score >= 100.0;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: ObsidianTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Completed successfully header (green tick)
              const Icon(
                Icons.check_circle,
                color: ObsidianTheme.tertiary,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                isPerfect ? 'Completed' : 'Completed Successfully',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.tertiary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Evaluation Score: ${score.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ObsidianTheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Recommendation details banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isPerfect
                      ? ObsidianTheme.tertiary.withValues(alpha: 0.08)
                      : ObsidianTheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPerfect ? ObsidianTheme.tertiary : ObsidianTheme.error,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPerfect ? Icons.verified : Icons.cancel,
                          color: isPerfect ? ObsidianTheme.tertiary : ObsidianTheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isPerfect ? 'Exam Passed' : 'Retest Recommended',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPerfect ? ObsidianTheme.tertiary : ObsidianTheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPerfect
                          ? 'Excellent job! Your performance data has been logged to the central database.'
                          : 'Your score does not meet the passing standard. We recommend studying the materials in the Study tab and retaking the exam.',
                      style: const TextStyle(
                        color: ObsidianTheme.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close sheet
                        ref.read(assessmentProvider.notifier).restartExam();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ObsidianTheme.primary,
                        side: const BorderSide(color: ObsidianTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Retest Exam', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close sheet
                        context.pop(); // Go back to dashboard
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreviewDialog() {
    final state = ref.read(assessmentProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ObsidianTheme.surfaceContainer,
        title: const Text('Exam Questions Preview', style: TextStyle(color: ObsidianTheme.onSurface, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              final isCurrent = state.currentIndex == index;
              final hasAnswer = state.answers.containsKey(index) &&
                  state.answers[index]!.values.any((val) => val != null && val.toString().isNotEmpty);

              return InkWell(
                onTap: () {
                  ref.read(assessmentProvider.notifier).jumpToQuestion(index);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? ObsidianTheme.primary
                        : (hasAnswer ? ObsidianTheme.tertiary.withValues(alpha: 0.15) : ObsidianTheme.surfaceContainerHighest),
                    border: Border.all(
                      color: isCurrent
                          ? ObsidianTheme.primary
                          : (hasAnswer ? ObsidianTheme.tertiary : ObsidianTheme.outlineVariant),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrent
                            ? const Color(0xFF0a0012)
                            : (hasAnswer ? ObsidianTheme.tertiary : ObsidianTheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ref.read(assessmentProvider.notifier).resetState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentProvider);

    if (state.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: ObsidianTheme.background,
        body: Center(child: Text('No active exam session.')),
      );
    }

    final question = state.questions[state.currentIndex];
    final isLast = state.currentIndex == state.questions.length - 1;
    final hasSaved = state.answers.containsKey(state.currentIndex);
    final hasSelected = state.selectedAnswers.containsKey(state.currentIndex);
    final canSave = !hasSaved;
    final canSaveAndQuit = hasSaved;

    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: TopAppBar(
        title: 'Exam Assessment (${state.difficulty.toUpperCase()})',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: ObsidianTheme.error),
            onPressed: _handleQuitDirectly,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    'Question ${state.currentIndex + 1} of ${state.questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (state.currentIndex + 1) / state.questions.length,
                      backgroundColor: ObsidianTheme.outlineVariant,
                      color: ObsidianTheme.primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),

            // Content Canvas (Compact & non-scrolling)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question Prompt
                    _buildPromptCard(state, question),
                    const SizedBox(height: 8),

                    // MCQ Selection Options
                    _buildMcqOptions(context, state),

                    // Correctness feedback area
                    if (hasSaved) ...[
                      const SizedBox(height: 8),
                      _buildFeedbackArea(state, question),
                    ],
                  ],
                ),
              ),
            ),

            // Glassmorphic Control Bar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: ObsidianTheme.outlineVariant)),
                color: ObsidianTheme.surfaceContainerLowest,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _showPreviewDialog,
                        child: Row(
                          children: const [
                            Icon(Icons.visibility, size: 16),
                            SizedBox(width: 6),
                            Text('Preview'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: canSave ? () {
                          if (!hasSelected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select an option before saving.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          final saved = ref.read(assessmentProvider.notifier).saveCurrentAnswer();
                          if (saved) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Answer selection saved.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSave 
                              ? ObsidianTheme.tertiary.withValues(alpha: 0.15) 
                              : ObsidianTheme.surfaceContainerHighest,
                          foregroundColor: canSave ? ObsidianTheme.tertiary : ObsidianTheme.onSurfaceVariant,
                          side: BorderSide(color: canSave ? ObsidianTheme.tertiary : ObsidianTheme.outlineVariant),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: canSaveAndQuit ? _handleSaveAndQuit : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ObsidianTheme.error,
                            side: BorderSide(color: canSaveAndQuit ? ObsidianTheme.error : ObsidianTheme.outlineVariant),
                          ),
                          child: const Text('Save & Quit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : () => _handleNext(state),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(isLast ? 'Submit Exam' : 'Next Question', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              Icon(isLast ? Icons.check : Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard(AssessmentState state, dynamic question) {
    String heading = "Generic Name";
    String value = question['generic_name'] ?? 'Unknown';
    String hint = "Identify the correct brand, dosage, and schedule for this drug.";

    if (state.difficulty == 'Medium') {
      heading = "Clinical Indication";
      value = question['indication'] ?? 'General clinical use';
      hint = "Provide the generic, associated brand, manufacturer, and schedule category.";
    } else if (state.difficulty == 'Hard') {
      heading = "Clinical Case Scenario";
      // Dynamic scenario builder
      final spec = question['speciality'].toString().split('|').first;
      value = "A patient presents to the $spec clinic. Clinicians need to start a medication matching: ${question['indication']}. The therapy involves selecting and administering the safest class.";
      hint = "Evaluate appropriate indications, recommended generics, contraindications, and adjust dosing.";
    }

    return PharmaQCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ObsidianTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ObsidianTheme.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              heading.toUpperCase(),
              style: const TextStyle(color: ObsidianTheme.primary, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.25),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMcqOptions(BuildContext context, AssessmentState state) {
    final options = state.mcqOptions[state.currentIndex] ?? [];
    if (options.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: ObsidianTheme.primary),
        ),
      );
    }

    final letters = ['A', 'B', 'C', 'D'];
    final question = state.questions[state.currentIndex];
    final hasSaved = state.answers.containsKey(state.currentIndex);
    final selectedAns = hasSaved
        ? state.answers[state.currentIndex]
        : state.selectedAnswers[state.currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(options.length, (index) {
        final opt = options[index];
        final letter = letters[index];
        
        final isUserSelected = selectedAns != null && selectedAns['brand_name'] == opt['brand_name'];
        final isCorrectOpt = opt['brand_name'] == question['drug_name'];

        Color borderColor = ObsidianTheme.outlineVariant;
        Color bgColor = ObsidianTheme.surfaceContainer;
        Color letterBgColor = ObsidianTheme.surfaceContainerHighest;
        Color letterTextColor = ObsidianTheme.onSurface;
        double borderSize = 1.0;

        if (hasSaved) {
          if (isCorrectOpt) {
            borderColor = ObsidianTheme.tertiary;
            bgColor = ObsidianTheme.tertiary.withValues(alpha: 0.08);
            letterBgColor = ObsidianTheme.tertiary;
            letterTextColor = const Color(0xFF0a0012);
            if (isUserSelected) borderSize = 2.0;
          } else if (isUserSelected) {
            borderColor = ObsidianTheme.error;
            bgColor = ObsidianTheme.error.withValues(alpha: 0.08);
            letterBgColor = ObsidianTheme.error;
            letterTextColor = Colors.white;
            borderSize = 2.0;
          }
        } else {
          if (isUserSelected) {
            borderColor = ObsidianTheme.primary;
            bgColor = ObsidianTheme.primary.withValues(alpha: 0.08);
            letterBgColor = ObsidianTheme.primary;
            letterTextColor = const Color(0xFF0a0012);
            borderSize = 2.0;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: hasSaved
                ? null
                : () {
                    ref.read(assessmentProvider.notifier).selectAnswer(opt);
                  },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: borderSize,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Option Letter Badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: letterBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasSaved
                            ? (isCorrectOpt || isUserSelected ? Colors.transparent : ObsidianTheme.outline)
                            : (isUserSelected ? Colors.transparent : ObsidianTheme.outline),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: letterTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Option Content Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.difficulty == 'Easy') ...[
                          Text(
                            opt['brand_name'] ?? 'Unknown Brand',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ObsidianTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              _buildCardBadge('${opt['strength'] ?? ''} • ${opt['dosage_form'] ?? ''}'),
                              _buildCardBadge('Schedule ${opt['schedule'] ?? ''}', color: ObsidianTheme.primary),
                              _buildCardBadge(opt['company'] ?? ''),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Indication: ${opt['indication'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: ObsidianTheme.onSurfaceVariant,
                            ),
                          ),
                        ] else if (state.difficulty == 'Medium') ...[
                          Text(
                            opt['generic_name'] ?? 'Unknown Generic',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ObsidianTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              _buildCardBadge('Brand: ${opt['brand_name'] ?? ''}'),
                              _buildCardBadge('Schedule ${opt['schedule'] ?? ''}', color: ObsidianTheme.primary),
                              _buildCardBadge(opt['company'] ?? ''),
                            ],
                          ),
                        ] else ...[
                          // Hard Mode
                          Text(
                            opt['contraindication'] ?? 'Unknown Contraindication',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ObsidianTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              _buildCardBadge('Generic: ${opt['generic_name'] ?? ''}'),
                              _buildCardBadge(opt['dosage'] ?? '', color: ObsidianTheme.primary),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rationale: ${opt['rationale'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: ObsidianTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCardBadge(String label, {Color? color}) {
    final badgeColor = color ?? ObsidianTheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String getCorrectOptionText(Map<String, dynamic> correctOption, String difficulty) {
    if (difficulty == 'Easy') {
      return '${correctOption['brand_name'] ?? ''} (${correctOption['strength'] ?? ''} • ${correctOption['dosage_form'] ?? ''}) - Schedule ${correctOption['schedule'] ?? ''}';
    } else if (difficulty == 'Medium') {
      return '${correctOption['generic_name'] ?? ''} (Brand: ${correctOption['brand_name'] ?? ''}) - Schedule ${correctOption['schedule'] ?? ''}';
    } else {
      return '${correctOption['contraindication'] ?? ''} (Generic: ${correctOption['generic_name'] ?? ''} • ${correctOption['dosage'] ?? ''})';
    }
  }

  Widget _buildFeedbackArea(AssessmentState state, dynamic question) {
    final options = state.mcqOptions[state.currentIndex] ?? [];
    final correctOption = options.firstWhere(
      (opt) => opt['brand_name'] == question['drug_name'],
      orElse: () => options.isNotEmpty ? options.first : {},
    );
    final savedAns = state.answers[state.currentIndex];
    final isCorrect = savedAns != null && savedAns['brand_name'] == question['drug_name'];

    final correctText = getCorrectOptionText(correctOption, state.difficulty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect
            ? ObsidianTheme.tertiary.withValues(alpha: 0.08)
            : ObsidianTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect ? ObsidianTheme.tertiary : ObsidianTheme.error,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: isCorrect ? ObsidianTheme.tertiary : ObsidianTheme.error,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct Answer' : 'Incorrect Answer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? ObsidianTheme.tertiary : ObsidianTheme.error,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Correct: $correctText',
            style: const TextStyle(
              color: ObsidianTheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
