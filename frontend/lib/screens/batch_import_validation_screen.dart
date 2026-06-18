import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';

class BatchImportValidationScreen extends StatelessWidget {
  const BatchImportValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'PharmaQ',
        actions: [
          const Center(child: Text('Validate Import', style: TextStyle(fontWeight: FontWeight.bold, color: ObsidianTheme.onSurfaceVariant))),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: ObsidianTheme.surfaceContainerHighest,
              child: const Icon(Icons.person, size: 16, color: ObsidianTheme.onSurfaceVariant),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryDashboard(),
                const SizedBox(height: 32),
                _buildDataPreviewSection(),
                const SizedBox(height: 32),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3), // Logs active maybe? HTML has history_edu active
    );
  }

  Widget _buildSummaryDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 700;
        Widget circleCard = Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ObsidianTheme.outlineVariant),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.95,
                      strokeWidth: 8,
                      backgroundColor: ObsidianTheme.surfaceContainerHighest,
                      color: ObsidianTheme.primary,
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('95%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('VALID', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('142 Ready', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Questions validated for import', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        );

        Widget errorsCard = Container(
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ObsidianTheme.outlineVariant),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: ObsidianTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                  border: Border(bottom: BorderSide(color: ObsidianTheme.outlineVariant)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.report, color: ObsidianTheme.error),
                        const SizedBox(width: 8),
                        const Text('8 Errors Found', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Download Report', style: TextStyle(fontSize: 12)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildErrorRow('Row 14', 'Missing Brand Name', 'CRITICAL', ObsidianTheme.error),
                    const SizedBox(height: 8),
                    _buildErrorRow('Row 28', 'Invalid Dosage Units', 'CRITICAL', ObsidianTheme.error),
                    const SizedBox(height: 8),
                    _buildErrorRow('Row 41', 'Category mismatch', 'WARNING', Colors.amber),
                    const SizedBox(height: 8),
                    _buildErrorRow('Row 55', 'Duplicate entry', 'CRITICAL', ObsidianTheme.error),
                  ],
                ),
              )
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: circleCard),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: errorsCard),
            ],
          );
        } else {
          return Column(
            children: [
              circleCard,
              const SizedBox(height: 16),
              errorsCard,
            ],
          );
        }
      }
    );
  }

  Widget _buildErrorRow(String row, String msg, String badgeText, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: ObsidianTheme.onSurface, fontSize: 14),
              children: [
                TextSpan(text: '$row: ', style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor)),
                TextSpan(text: msg),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
            child: Text(badgeText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildDataPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Data Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Showing 3 of 142 valid rows', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 700;
            return GridView.count(
              crossAxisCount: isWide ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isWide ? 2.5 : 2,
              children: [
                _buildPreviewCard('Row 01', 'Antibiotics', 'Amoxicillin', 'Primary indication: Bacterial infections including pneumonia and bronchitis. Question focuses on dosage adjustment for renal impairment.', ['Pharmacokinetics', 'Penicillin']),
                _buildPreviewCard('Row 02', 'Analgesics', 'Fentanyl', 'Opioid agonist interaction study. Question focuses on respiratory depression mechanisms and antidote protocols.', ['Opioids', 'Critical Care']),
                _buildStatsVisualizer(),
                _buildDatabaseImpact(),
              ],
            );
          }
        )
      ],
    );
  }

  Widget _buildPreviewCard(String row, String cat, String title, String desc, List<String> tags) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$row • $cat'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ObsidianTheme.primary, letterSpacing: 1.2)),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.check_circle, color: ObsidianTheme.tertiary),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: ObsidianTheme.onSurfaceVariant)),
          const Spacer(),
          Row(
            children: tags.map((t) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ObsidianTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ObsidianTheme.outlineVariant),
              ),
              child: Text(t, style: const TextStyle(fontSize: 10)),
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildStatsVisualizer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Tags Created', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
              Text('12', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: ObsidianTheme.tertiary)),
            ],
          ),
          Text('System-wide taxonomy update will occur', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: ObsidianTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildDatabaseImpact() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Import Logic', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildLogicRow('Skip duplicate records'),
          _buildLogicRow('Auto-tag chemical classes'),
          _buildLogicRow('Archive previous batch #110'),
        ],
      ),
    );
  }

  Widget _buildLogicRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: ObsidianTheme.primary, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, color: ObsidianTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
            child: const Text('Confirm Import (142 Questions)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32)),
          child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurfaceVariant)),
        )
      ],
    );
  }
}
