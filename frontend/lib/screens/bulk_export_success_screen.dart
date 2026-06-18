import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';

class BulkExportSuccessScreen extends StatelessWidget {
  const BulkExportSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'PharmaQ',
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: ObsidianTheme.onSurfaceVariant),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 700;
                
                Widget mainCard = _buildMainStatusCard();
                Widget sideCard = _buildSupplementalInfoCard();

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: mainCard),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: sideCard),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      mainCard,
                      const SizedBox(height: 24),
                      sideCard,
                    ],
                  );
                }
              }
            )
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatusCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ObsidianTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 48, color: ObsidianTheme.primary),
          ),
          const SizedBox(height: 24),
          const Text('Export Successfully Generated', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Your pharmacology question data has been compiled and is ready for clinical review or offline study.', style: TextStyle(fontSize: 16, color: ObsidianTheme.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ObsidianTheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ObsidianTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.description, color: ObsidianTheme.primary),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('clinical_export_2023.xlsx', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('4.2 MB • Microsoft Excel', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
                      ],
                    )
                  ],
                ),
                const Icon(Icons.verified, color: ObsidianTheme.onSurfaceVariant),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Download File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Back to Question Bank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSupplementalInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ObsidianTheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('EXPORT SUMMARY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: ObsidianTheme.onSurface)),
              const SizedBox(height: 24),
              _buildSummaryRow('Questions', '1,240', isHighlighted: true),
              const Divider(color: ObsidianTheme.outlineVariant, height: 32),
              _buildSummaryRow('Format', 'XLSX'),
              const Divider(color: ObsidianTheme.outlineVariant, height: 32),
              _buildSummaryRow('Generated', 'Just Now'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 192,
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ObsidianTheme.outlineVariant),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ObsidianTheme.background.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('SECURITY VERIFIED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: ObsidianTheme.primary)),
          ),
        )
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: ObsidianTheme.onSurfaceVariant)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal, fontFamily: isHighlighted ? 'monospace' : null, color: isHighlighted ? ObsidianTheme.tertiary : ObsidianTheme.onSurface)),
      ],
    );
  }
}
