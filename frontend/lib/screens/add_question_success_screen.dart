import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/obsidian_theme.dart';
import '../components/pharmaq_card.dart';
import '../components/top_app_bar.dart';

class AddQuestionSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> questionData;

  const AddQuestionSuccessScreen({super.key, required this.questionData});

  @override
  Widget build(BuildContext context) {
    final ved = questionData['ved'].toString().toUpperCase();
    String diffText = 'Easy Mode (Identification)';
    if (ved == 'V') {
      diffText = 'Hard Mode (Scenario)';
    } else if (ved == 'E' && questionData['schedule'] == 'H') {
      diffText = 'Medium Mode (Associative)';
    }

    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: const TopAppBar(
        title: 'PharmaQ Editor',
        showBackButton: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ObsidianTheme.tertiary.withValues(alpha: 0.1),
                  border: Border.all(color: ObsidianTheme.tertiary, width: 2),
                ),
                child: const Icon(Icons.check_circle, color: ObsidianTheme.tertiary, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Question Published', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Your clinical pharmacology case has been verified and added to the core bank.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ObsidianTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              PharmaQCard(
                child: Column(
                  children: [
                    _buildRow('Generic Molecule', questionData['generic_name'] ?? 'N/A'),
                    const Divider(color: ObsidianTheme.outlineVariant),
                    _buildRow('Associated Brand', questionData['drug_name'] ?? 'N/A'),
                    const Divider(color: ObsidianTheme.outlineVariant),
                    _buildRow('Difficulty Setting', diffText),
                    const Divider(color: ObsidianTheme.outlineVariant),
                    _buildRow('Primary Indication', questionData['indication'] ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.go('/mentor/add-question/details', extra: null);
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Add Another Question', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  context.go('/dashboard');
                },
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Return to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              val, 
              textAlign: Alignment.centerRight.x > 0 ? TextAlign.right : TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface, fontSize: 13, overflow: TextOverflow.ellipsis)
            ),
          ),
        ],
      ),
    );
  }
}
