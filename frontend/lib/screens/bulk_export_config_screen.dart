import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/pharmaq_card.dart';

class BulkExportConfigScreen extends StatelessWidget {
  const BulkExportConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Export Questions',
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 32),
                _buildFiltersSection(),
                const SizedBox(height: 24),
                _buildSummaryCard(),
                const SizedBox(height: 32),
                _buildFormatSelection(),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _buildBottomActionBar(),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(1, 'Configure', isActive: true),
        Container(
          width: 48,
          height: 1,
          color: ObsidianTheme.outlineVariant,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Opacity(
          opacity: 0.4,
          child: _buildStep(2, 'Review', isActive: false),
        ),
      ],
    );
  }

  Widget _buildStep(int number, String text, {required bool isActive}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? ObsidianTheme.primary : ObsidianTheme.surfaceContainer,
            border: Border.all(color: isActive ? ObsidianTheme.primary : ObsidianTheme.outlineVariant),
          ),
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: TextStyle(
              color: isActive ? ObsidianTheme.onSurface : ObsidianTheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isActive ? ObsidianTheme.primary : ObsidianTheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600;
        Widget categoryFilter = PharmaQCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.category, size: 16, color: ObsidianTheme.onSurfaceVariant),
                  SizedBox(width: 8),
                  Text('CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('Antibiotics', isSelected: true),
                  _buildFilterChip('Narcotics', isSelected: false),
                  _buildFilterChip('Cardiology', isSelected: false),
                  _buildFilterChip('+ More', isSelected: false),
                ],
              )
            ],
          ),
        );

        Widget difficultyFilter = PharmaQCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.reorder, size: 16, color: ObsidianTheme.onSurfaceVariant),
                  SizedBox(width: 8),
                  Text('DIFFICULTY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDiffSelect('Easy', isSelected: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDiffSelect('Medium', isSelected: false)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDiffSelect('Hard', isSelected: false)),
                ],
              )
            ],
          ),
        );

        Widget dateRangeFilter = PharmaQCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: ObsidianTheme.onSurfaceVariant),
                  SizedBox(width: 8),
                  Text('DATE RANGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDateInput()),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('to', style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
                  ),
                  Expanded(child: _buildDateInput()),
                ],
              )
            ],
          ),
        );

        return Column(
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: categoryFilter),
                  const SizedBox(width: 16),
                  Expanded(child: difficultyFilter),
                ],
              )
            else
              Column(
                children: [
                  categoryFilter,
                  const SizedBox(height: 16),
                  difficultyFilter,
                ],
              ),
            const SizedBox(height: 16),
            dateRangeFilter,
          ],
        );
      }
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? ObsidianTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? ObsidianTheme.primary : ObsidianTheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? ObsidianTheme.primary : ObsidianTheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDiffSelect(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? ObsidianTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? ObsidianTheme.primary : ObsidianTheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? ObsidianTheme.primary : ObsidianTheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ObsidianTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ObsidianTheme.outlineVariant),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('dd/mm/yyyy', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 14)),
          Icon(Icons.calendar_today, size: 16, color: ObsidianTheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: ObsidianTheme.primary, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1,240', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface)),
              Text('Questions Selected', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
            ],
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: ObsidianTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics, size: 32, color: ObsidianTheme.primary),
          )
        ],
      ),
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('EXPORT FORMAT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurfaceVariant, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 500;
            Widget excelCard = _buildFormatCard(
              'Excel (.xlsx)',
              'Structured data with formulas and formatting.',
              Icons.table_view,
              isSelected: true,
            );
            Widget csvCard = _buildFormatCard(
              'CSV',
              'Lightweight, plain-text comma separated values.',
              Icons.insert_drive_file,
              isSelected: false,
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: excelCard),
                  const SizedBox(width: 16),
                  Expanded(child: csvCard),
                ],
              );
            } else {
              return Column(
                children: [
                  excelCard,
                  const SizedBox(height: 16),
                  csvCard,
                ],
              );
            }
          }
        )
      ],
    );
  }

  Widget _buildFormatCard(String title, String desc, IconData icon, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isSelected ? ObsidianTheme.primary.withValues(alpha: 0.05) : ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? ObsidianTheme.primary : ObsidianTheme.outlineVariant),
      ),
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
            child: Icon(icon, color: isSelected ? ObsidianTheme.primary : ObsidianTheme.tertiary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? ObsidianTheme.primary : ObsidianTheme.outlineVariant,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: isSelected
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: ObsidianTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          )
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: ObsidianTheme.background,
        border: Border(top: BorderSide(color: ObsidianTheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: ObsidianTheme.onSurface,
                side: const BorderSide(color: ObsidianTheme.outlineVariant),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Save Draft'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Row(
                children: [
                  Text('Next: Review Selection', style: TextStyle(fontWeight: FontWeight.bold)),
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
