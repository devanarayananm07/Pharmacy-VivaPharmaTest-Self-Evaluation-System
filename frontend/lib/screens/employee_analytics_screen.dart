import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/pharmaq_card.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';

class EmployeeAnalyticsScreen extends StatelessWidget {
  const EmployeeAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(
        title: 'Employee Progress',
        actions: [
          Icon(Icons.more_vert),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: ObsidianTheme.primary,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: ObsidianTheme.background,
                    child: const Text('SC', style: TextStyle(fontSize: 24, color: ObsidianTheme.primary)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sarah Chen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Clinical Pharmacist • PGY-2 Resident', style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildChip('ID: #88241'),
                          const SizedBox(width: 8),
                          _buildChip('Dept: Medicine'),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            // Target
            PharmaQCard(
              child: Column(
                children: [
                  const Text('WEEKLY TARGET', style: TextStyle(fontSize: 12, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 0.75,
                          strokeWidth: 8,
                          backgroundColor: ObsidianTheme.outlineVariant,
                          color: ObsidianTheme.primary,
                        ),
                      ),
                      const Column(
                        children: [
                          Text('75%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('Completion', style: TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('112 / 150 questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Category Performance
            PharmaQCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CATEGORY PERFORMANCE', style: TextStyle(fontSize: 12, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  _buildCategoryPerf('Antibiotics', '92%', ObsidianTheme.tertiary),
                  _buildCategoryPerf('Narcotics', '64%', ObsidianTheme.primary),
                  _buildCategoryPerf('Cardiology', '81%', ObsidianTheme.onSurface),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Send Reminder'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildCategoryPerf(String title, String score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(score, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
