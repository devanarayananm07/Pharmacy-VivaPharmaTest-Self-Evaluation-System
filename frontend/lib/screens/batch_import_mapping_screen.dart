import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';

class BatchImportMappingScreen extends StatelessWidget {
  const BatchImportMappingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'PharmaQ',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: ObsidianTheme.onSurfaceVariant),
            onPressed: () {},
          ),
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSettingsControls(),
                const SizedBox(height: 24),
                _buildMappingGrid(),
                const SizedBox(height: 32),
                _buildHintCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      bottomSheet: _buildBottomActionBar(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Batch Import', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right, size: 16, color: ObsidianTheme.onSurfaceVariant),
            const Text('Step 2: Field Mapping', style: TextStyle(color: ObsidianTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Map Clinical Data', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface)),
        const SizedBox(height: 8),
        const Text(
          'Connect your spreadsheet columns to PharmaQ\'s system architecture. We\'ve attempted to auto-match fields based on semantic similarity.',
          style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSettingsControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Switch(
                value: true,
                onChanged: (v) {},
                activeThumbColor: ObsidianTheme.background,
                activeTrackColor: ObsidianTheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('First row contains headers', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: ObsidianTheme.onSurfaceVariant),
              SizedBox(width: 8),
              Text('150 rows detected in \'clinical_trial_batch_04.xlsx\'', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMappingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600;
        return Column(
          children: [
            if (isWide)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(child: Text('EXCEL COLUMNS', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                    const SizedBox(width: 48),
                    Expanded(child: Text('SYSTEM FIELDS', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                  ],
                ),
              ),
            _buildMappingRow('Column A', 'GENERIC_NAME_VAL', 'Generic Name', Icons.medication, isWide),
            const SizedBox(height: 16),
            _buildMappingRow('Column B', 'PRODUCT_TRADE_ID', 'Brand Name', Icons.label, isWide),
            const SizedBox(height: 16),
            _buildMappingRow('Column C', 'MEDICAL_CONDITION', 'Indication', Icons.medical_services, isWide),
            const SizedBox(height: 16),
            _buildMappingRow('Column D', 'CONCENTRATION_MG', 'Dosage', Icons.monitor_weight, isWide),
            const SizedBox(height: 16),
            _buildMappingRow('Column E', 'RECURRENCE_FREQ', 'Schedule', Icons.calendar_today, isWide),
          ],
        );
      }
    );
  }

  Widget _buildMappingRow(String colId, String colName, String selectedField, IconData icon, bool isWide) {
    Widget left = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(colId, style: const TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
          Text(colName, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );

    Widget right = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: ObsidianTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedField,
                isExpanded: true,
                dropdownColor: ObsidianTheme.surfaceContainerHighest,
                icon: const Icon(Icons.arrow_drop_down, color: ObsidianTheme.onSurfaceVariant),
                items: ['Generic Name', 'Brand Name', 'Indication', 'Dosage', 'Schedule']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {},
              ),
            ),
          )
        ],
      ),
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(child: left),
          SizedBox(
            width: 48,
            child: Divider(color: ObsidianTheme.outlineVariant, thickness: 1),
          ),
          Expanded(child: right),
        ],
      );
    } else {
      return Column(
        children: [
          left,
          const Icon(Icons.arrow_downward, color: ObsidianTheme.outlineVariant, size: 20),
          right,
        ],
      );
    }
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ObsidianTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: ObsidianTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Smart Suggestion', style: TextStyle(fontWeight: FontWeight.bold, color: ObsidianTheme.primary)),
                const SizedBox(height: 4),
                Text(
                  'Remaining columns (F-J) were not automatically matched. You can manually map them or skip them in the next step.',
                  style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: ObsidianTheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: ObsidianTheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: ObsidianTheme.tertiary, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('Scanning 150 rows...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Text('5/12 fields mapped successfully', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Row(
                children: [
                  Text('Next: Validate Data', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
