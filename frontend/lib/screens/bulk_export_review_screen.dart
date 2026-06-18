import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';

class BulkExportReviewScreen extends StatelessWidget {
  const BulkExportReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'PharmaQ',
        actions: [
          const Icon(Icons.medical_services, color: ObsidianTheme.primary),
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
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildMetadataCard(),
                const SizedBox(height: 32),
                _buildDataPreviewList(),
                const SizedBox(height: 32),
                _buildSecureExportToggleCard(),
                const SizedBox(height: 48),
                _buildActionArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: ObsidianTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: ObsidianTheme.primary.withValues(alpha: 0.2)),
          ),
          child: const Text('Step 2 of 2', style: TextStyle(color: ObsidianTheme.primary, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 8),
        const Text('Review Export', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface)),
        const SizedBox(height: 8),
        const Text('Verify the data integrity and security settings before generating the clinical file.', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 16)),
      ],
    );
  }

  Widget _buildMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ObsidianTheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ObsidianTheme.tertiary.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.description, color: ObsidianTheme.tertiary),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exporting 1,240 rows', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: ObsidianTheme.onSurface)),
                Text('clinical_export_2023.xlsx', style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: ObsidianTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ObsidianTheme.outlineVariant),
            ),
            child: const Column(
              children: [
                Text('TARGET FORMAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: ObsidianTheme.tertiary)),
                Text('Excel Spreadsheet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ObsidianTheme.onSurface)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDataPreviewList() {
    return Container(
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: ObsidianTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(bottom: BorderSide(color: ObsidianTheme.outlineVariant)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DATA PREVIEW (SAMPLE)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
                Text('Showing 5 of 1,240 items', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: ObsidianTheme.tertiary)),
              ],
            ),
          ),
          _buildListItem('Amoxicillin Interaction Protocol', 'Antibiotics', 'Easy', ObsidianTheme.tertiary),
          _buildDivider(),
          _buildListItem('Fentanyl Dosage Calculations', 'Analgesics', 'Hard', ObsidianTheme.error),
          _buildDivider(),
          _buildListItem('Atorvastatin Side Effect Analysis', 'Statins', 'Medium', ObsidianTheme.primary),
          _buildDivider(),
          _buildListItem('Metformin Contraindications', 'Antidiabetics', 'Medium', ObsidianTheme.primary),
          _buildDivider(),
          _buildListItem('Warfarin Monitoring Guidelines', 'Anticoagulants', 'Hard', ObsidianTheme.error),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, color: ObsidianTheme.outlineVariant);

  Widget _buildListItem(String title, String category, String difficulty, Color diffColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: ObsidianTheme.onSurface)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ObsidianTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: ObsidianTheme.outlineVariant),
                    ),
                    child: Text(category, style: const TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: diffColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: diffColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(difficulty, style: TextStyle(fontSize: 10, color: diffColor)),
                  ),
                ],
              )
            ],
          ),
          const Icon(Icons.visibility, color: ObsidianTheme.outlineVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildSecureExportToggleCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock, color: ObsidianTheme.primary),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Secure Export Toggle', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: ObsidianTheme.onSurface)),
                    SizedBox(height: 4),
                    Text('Apply password protection to file for HIPAA-compliant transmission.', style: TextStyle(fontSize: 14, color: ObsidianTheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(
                value: true,
                onChanged: (v) {},
                activeThumbColor: ObsidianTheme.background,
                activeTrackColor: ObsidianTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: ObsidianTheme.outlineVariant),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FILE PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ObsidianTheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ObsidianTheme.outlineVariant)),
                  suffixIcon: const Icon(Icons.visibility_off, color: ObsidianTheme.onSurfaceVariant),
                ),
                controller: TextEditingController(text: '********'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ObsidianTheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {},
            child: const Text('Cancel Export', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ObsidianTheme.onSurfaceVariant)),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('Generate Export', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
          )
        ],
      ),
    );
  }
}
