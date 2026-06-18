import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../components/pharmaq_card.dart';

class BatchImportUploadScreen extends StatelessWidget {
  const BatchImportUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Batch Import',
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ObsidianTheme.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: ObsidianTheme.tertiary),
                const SizedBox(width: 8),
                Text('Step 1 of 3', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: ObsidianTheme.primary.withValues(alpha: 0.2),
              child: const Icon(Icons.person, size: 16, color: ObsidianTheme.primary),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(),
                const SizedBox(height: 32),
                _buildTemplateSection(),
                const SizedBox(height: 24),
                _buildUploadSection(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: null, // Disabled by default
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ObsidianTheme.surfaceContainerHighest,
                    foregroundColor: ObsidianTheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Next: Map Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(1, 'Selection', isActive: true),
        Expanded(child: Container(height: 1, color: ObsidianTheme.outlineVariant)),
        _buildStep(2, 'Mapping', isActive: false),
        Expanded(child: Container(height: 1, color: ObsidianTheme.outlineVariant)),
        _buildStep(3, 'Review', isActive: false),
      ],
    );
  }

  Widget _buildStep(int number, String label, {required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? ObsidianTheme.primary : ObsidianTheme.surfaceContainer,
            border: Border.all(
              color: isActive ? ObsidianTheme.primary : ObsidianTheme.outlineVariant,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: TextStyle(
              color: isActive ? ObsidianTheme.background : ObsidianTheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isActive ? ObsidianTheme.primary : ObsidianTheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateSection() {
    return PharmaQCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ObsidianTheme.outlineVariant),
            ),
            child: const Icon(Icons.note_add, color: ObsidianTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Download Excel Template', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Ensure data follows the required pharmacological schema to avoid validation errors during mapping.',
                  style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 14),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download Template (.xlsx)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ObsidianTheme.primary,
                    side: const BorderSide(color: ObsidianTheme.outlineVariant),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ObsidianTheme.outlineVariant,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ObsidianTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.upload_file, size: 40, color: ObsidianTheme.primary),
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface),
                  children: [
                    TextSpan(text: 'Drag & drop Excel file or '),
                    TextSpan(text: 'Browse', style: TextStyle(color: ObsidianTheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Supported format: .xlsx', style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: ObsidianTheme.onSurfaceVariant),
                SizedBox(width: 8),
                Text('Max file size: 10MB', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
              ],
            ),
            Row(
              children: [
                Icon(Icons.security, size: 16, color: ObsidianTheme.tertiary),
                SizedBox(width: 8),
                Text('Encrypted transmission', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
              ],
            ),
          ],
        )
      ],
    );
  }
}
