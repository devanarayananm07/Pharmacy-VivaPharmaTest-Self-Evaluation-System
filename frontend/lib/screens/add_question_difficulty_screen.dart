import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/obsidian_theme.dart';
import '../components/pharmaq_card.dart';
import '../components/top_app_bar.dart';
import '../providers/admin_provider.dart';

class AddQuestionDifficultyScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> questionData;

  const AddQuestionDifficultyScreen({super.key, required this.questionData});

  @override
  ConsumerState<AddQuestionDifficultyScreen> createState() => _AddQuestionDifficultyScreenState();
}

class _AddQuestionDifficultyScreenState extends ConsumerState<AddQuestionDifficultyScreen> {
  String _difficulty = 'Medium';
  bool _excludeDuplicates = false;
  bool _urgentReview = false;
  bool _isPublishing = false;

  void _handlePublish() async {
    setState(() => _isPublishing = true);

    final isEdit = widget.questionData.containsKey('id');
    final finalQuestion = Map<String, dynamic>.from(widget.questionData);

    // Apply defaults depending on difficulty
    if (_difficulty == 'Easy') {
      finalQuestion['ved'] = 'E';
      finalQuestion['abc'] = 'C';
      finalQuestion['sku'] = 'Y';
      finalQuestion['days'] = 'Day 001';
      finalQuestion['store'] = 'Main Pharmacy A';
      finalQuestion['store_code'] = '101';
      finalQuestion['speciality'] = 'General Medicine';
      finalQuestion['schedule'] = 'OTC';
    } else if (_difficulty == 'Medium') {
      finalQuestion['ved'] = 'E';
      finalQuestion['abc'] = 'B';
      finalQuestion['sku'] = 'Y';
      finalQuestion['days'] = 'Day 005';
      finalQuestion['store'] = 'Outpatient Pharmacy';
      finalQuestion['store_code'] = '102';
      finalQuestion['speciality'] = 'General Medicine';
      finalQuestion['schedule'] = 'H';
    } else {
      finalQuestion['ved'] = 'V';
      finalQuestion['abc'] = 'A';
      finalQuestion['sku'] = 'Y';
      finalQuestion['days'] = 'Day 012';
      finalQuestion['store'] = 'Pharmacy Store/Oncology-T2F0-V';
      finalQuestion['store_code'] = '131';
      finalQuestion['speciality'] = 'Cardiology|General Medcine';
      finalQuestion['schedule'] = 'H';
    }

    finalQuestion['generic_rating'] = _difficulty == 'Hard' ? '250' : (_difficulty == 'Medium' ? '180' : '100');

    bool success;
    if (isEdit) {
      success = await ref.read(adminProvider.notifier).updateQuestion(finalQuestion);
    } else {
      success = await ref.read(adminProvider.notifier).createQuestion(finalQuestion);
    }

    setState(() => _isPublishing = false);

    if (success && mounted) {
      context.push('/mentor/add-question/success', extra: finalQuestion);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to publish question to server.'), backgroundColor: ObsidianTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.questionData.containsKey('id');

    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: const TopAppBar(
        title: 'PharmaQ Editor',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('STEP 2 OF 3', style: TextStyle(color: ObsidianTheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text(isEdit ? 'Review & Save' : 'Configure Difficulty', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Define the cognitive load and complexity parameters.', style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
            const SizedBox(height: 24),

            _buildDiffCard('Easy', 'Foundational knowledge. Displays Generic Name.', _difficulty == 'Easy'),
            _buildDiffCard('Medium', 'Associative logic. Displays Clinical Indication.', _difficulty == 'Medium'),
            _buildDiffCard('Hard', 'Clinical mastery. Scenario-based prompt.', _difficulty == 'Hard'),

            const SizedBox(height: 24),
            PharmaQCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Rules', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _excludeDuplicates,
                    onChanged: (v) => setState(() => _excludeDuplicates = v!),
                    title: const Text('Exclude from Easy Duplicate Check'),
                    subtitle: const Text('Allows similar formulations to coexist.', style: TextStyle(fontSize: 12)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _urgentReview,
                    onChanged: (v) => setState(() => _urgentReview = v!),
                    title: const Text('Flag for Urgent Review', style: TextStyle(color: ObsidianTheme.error)),
                    subtitle: const Text('Marks the question for senior verification.', style: TextStyle(fontSize: 12)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: ObsidianTheme.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Back'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isPublishing ? null : _handlePublish,
                child: _isPublishing
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: ObsidianTheme.background, strokeWidth: 2))
                    : Text(isEdit ? 'Save Changes' : 'Publish Question'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiffCard(String title, String desc, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => setState(() => _difficulty = title),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? ObsidianTheme.primary.withValues(alpha: 0.1) : ObsidianTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? ObsidianTheme.primary : ObsidianTheme.outlineVariant),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (isSelected) const Icon(Icons.check_circle, color: ObsidianTheme.primary),
                ],
              ),
              const SizedBox(height: 8),
              Text(desc, style: const TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
