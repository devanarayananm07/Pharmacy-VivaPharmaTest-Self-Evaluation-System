import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/obsidian_theme.dart';
import '../components/pharmaq_card.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../providers/admin_provider.dart';

class QuestionBankEditorScreen extends ConsumerStatefulWidget {
  const QuestionBankEditorScreen({super.key});

  @override
  ConsumerState<QuestionBankEditorScreen> createState() => _QuestionBankEditorScreenState();
}

class _QuestionBankEditorScreenState extends ConsumerState<QuestionBankEditorScreen> {
  String _searchQuery = '';
  String _selectedDifficulty = 'All'; // All, Easy, Medium, Hard
  bool _isFetched = false;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = _isFetched ? ref.watch(adminQuestionsProvider) : null;

    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: const TopAppBar(
        title: 'Question Bank Editor',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search drug by Generic or Brand Name...',
                prefixIcon: Icon(Icons.search, color: ObsidianTheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', _selectedDifficulty == 'All'),
                  _buildFilterChip('Easy', _selectedDifficulty == 'Easy'),
                  _buildFilterChip('Medium', _selectedDifficulty == 'Medium'),
                  _buildFilterChip('Hard', _selectedDifficulty == 'Hard'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Questions List
            if (questionsAsync == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.quiz_outlined, size: 64, color: ObsidianTheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      const Text(
                        'Question bank is not loaded.',
                        style: TextStyle(color: ObsidianTheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isFetched = true),
                        icon: const Icon(Icons.download),
                        label: const Text(
                          'Load Question Bank',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              questionsAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: CircularProgressIndicator(color: ObsidianTheme.primary))),
                error: (err, _) => Center(child: Text('Error loading questions: $err', style: const TextStyle(color: ObsidianTheme.error))),
              data: (questions) {
                // Apply local search query
                Iterable<dynamic> filtered = questions;
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  filtered = filtered.where((q) =>
                    q['generic_name'].toString().toLowerCase().contains(query) ||
                    q['drug_name'].toString().toLowerCase().contains(query)
                  );
                }

                // Apply difficulty level filtering
                final list = filtered.toList();
                final List<dynamic> finalResult = [];

                for (var q in list) {
                  final ved = q['ved'].toString().toUpperCase();
                  final schedule = q['schedule'].toString().toUpperCase();
                  String diff = 'Easy';
                  if (ved == 'V') {
                    diff = 'Hard';
                  } else if (ved == 'E' && schedule == 'H') {
                    diff = 'Medium';
                  }

                  if (_selectedDifficulty != 'All' && _selectedDifficulty != diff) {
                    continue;
                  }
                  finalResult.add(q);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUESTIONS (${finalResult.length})',
                      style: const TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (finalResult.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Text('No questions match selection.', style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
                        ),
                      )
                    else
                      ...finalResult.map((q) {
                        final ved = q['ved'].toString().toUpperCase();
                        final schedule = q['schedule'].toString().toUpperCase();
                        String diff = 'Easy';
                        Color diffColor = ObsidianTheme.tertiary;

                        if (ved == 'V') {
                          diff = 'Hard';
                          diffColor = ObsidianTheme.error;
                        } else if (ved == 'E' && schedule == 'H') {
                          diff = 'Medium';
                          diffColor = Colors.orange;
                        }

                        return _buildQuestionCard(q, diff, diffColor);
                      }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/mentor/add-question/details', extra: null);
        },
        backgroundColor: ObsidianTheme.primary,
        child: const Icon(Icons.add, color: Color(0xFF0a0012)),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedDifficulty = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ObsidianTheme.primary : ObsidianTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? ObsidianTheme.primary : ObsidianTheme.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0a0012) : ObsidianTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q, String difficulty, Color diffColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: PharmaQCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              q['generic_name'] ?? 'N/A', 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${q['drug_name'] ?? ''})', 
                            style: const TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 13, overflow: TextOverflow.ellipsis)
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Manufacturer: ${q['company'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
                      Text('Speciality: ${q['speciality'] ?? 'General'}', style: const TextStyle(fontSize: 12, color: ObsidianTheme.outline)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: diffColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(difficulty, style: TextStyle(color: diffColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: ObsidianTheme.outlineVariant),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: ObsidianTheme.onSurfaceVariant), 
                  onPressed: () => _showQuestionDetailsDialog(q)
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: ObsidianTheme.onSurfaceVariant), 
                  onPressed: () {
                    context.push('/mentor/add-question/details', extra: q);
                  }
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: ObsidianTheme.error), 
                  onPressed: () => _handleDeleteQuestion(q['id'])
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showQuestionDetailsDialog(Map<String, dynamic> q) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ObsidianTheme.surfaceContainer,
        title: Text(q['generic_name'] ?? 'Question Details', style: const TextStyle(color: ObsidianTheme.onSurface, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogRow('Brand Name', q['drug_name']),
              _buildDialogRow('Manufacturer', q['company']),
              _buildDialogRow('Indication', q['indication']),
              _buildDialogRow('Strength/Dosage', q['gsp']),
              _buildDialogRow('Schedule', q['schedule']),
              _buildDialogRow('Store', q['store']),
              _buildDialogRow('Days Requirement', q['days']),
            ],
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

  Widget _buildDialogRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: ObsidianTheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value ?? 'N/A', style: const TextStyle(color: ObsidianTheme.onSurface, fontSize: 13)),
          const SizedBox(height: 6),
          const Divider(color: ObsidianTheme.outlineVariant, height: 1),
        ],
      ),
    );
  }

  void _handleDeleteQuestion(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ObsidianTheme.surfaceContainer,
        title: const Text('Delete Question?', style: TextStyle(color: ObsidianTheme.onSurface, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to permanently delete this question from the database?', style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await ref.read(adminProvider.notifier).deleteQuestion(id.toString());
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question deleted successfully.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete question.'), backgroundColor: ObsidianTheme.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: ObsidianTheme.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
