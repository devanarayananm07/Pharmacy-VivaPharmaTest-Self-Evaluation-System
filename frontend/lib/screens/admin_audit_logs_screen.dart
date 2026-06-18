import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/pharmaq_card.dart';

class AdminAuditLogsScreen extends StatelessWidget {
  const AdminAuditLogsScreen({super.key});

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? ObsidianTheme.primary.withValues(alpha: 0.2) : ObsidianTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? ObsidianTheme.primary.withValues(alpha: 0.5) : ObsidianTheme.outlineVariant,
        ),
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

  Widget _buildLogCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String category,
    required Color categoryColor,
    required String time,
    required String title,
    required String user,
    required String tag,
    required Color tagColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: PharmaQCard(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: iconColor.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: categoryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ObsidianTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ObsidianTheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        user,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ObsidianTheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.1),
                          border: Border.all(color: tagColor.withValues(alpha: 0.2)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: tagColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: ObsidianTheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(
        title: 'Audit Logs',
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: ObsidianTheme.onSurfaceVariant),
            onPressed: null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search & Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: ObsidianTheme.onSurfaceVariant),
                        hintText: 'Search by user ID, action, or date...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All Logs', isSelected: true),
                          const SizedBox(width: 8),
                          _buildFilterChip('Security'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Database'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Users'),
                          const SizedBox(width: 8),
                          _buildFilterChip('System'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Logs List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildLogCard(
                      icon: Icons.security,
                      iconColor: ObsidianTheme.error,
                      iconBgColor: ObsidianTheme.error.withValues(alpha: 0.2),
                      category: 'SECURITY ALERT',
                      categoryColor: ObsidianTheme.error,
                      time: 'Oct 26, 2023 • 14:45',
                      title: 'Unauthorized access attempt blocked from IP 192.168.1.105',
                      user: 'System Shield',
                      tag: 'Critical',
                      tagColor: ObsidianTheme.error,
                    ),
                    _buildLogCard(
                      icon: Icons.storage,
                      iconColor: ObsidianTheme.tertiary,
                      iconBgColor: ObsidianTheme.tertiary.withValues(alpha: 0.2),
                      category: 'DATABASE UPDATE',
                      categoryColor: ObsidianTheme.tertiary,
                      time: 'Oct 26, 2023 • 14:30',
                      title: 'Dr. Aris Thorne updated Amoxicillin clinical guidelines',
                      user: 'Aris Thorne (Mentor)',
                      tag: 'Info',
                      tagColor: ObsidianTheme.tertiary,
                    ),
                    _buildLogCard(
                      icon: Icons.manage_accounts,
                      iconColor: ObsidianTheme.primary,
                      iconBgColor: ObsidianTheme.primary.withValues(alpha: 0.1),
                      category: 'ROLE MODIFIED',
                      categoryColor: ObsidianTheme.primary,
                      time: 'Oct 26, 2023 • 12:12',
                      title: 'Sarah Jenkins promoted to \'Senior Editor\' in Question Bank',
                      user: 'Mark Vance (Admin)',
                      tag: 'Modified',
                      tagColor: ObsidianTheme.primary,
                    ),
                    _buildLogCard(
                      icon: Icons.delete_forever,
                      iconColor: ObsidianTheme.onSurfaceVariant,
                      iconBgColor: ObsidianTheme.surfaceContainerHighest,
                      category: 'CONTENT PURGED',
                      categoryColor: ObsidianTheme.onSurfaceVariant,
                      time: 'Oct 25, 2023 • 23:45',
                      title: 'Deleted 4 outdated mock exams (Batch ID: #EX-992)',
                      user: 'Auto-System',
                      tag: 'Deleted',
                      tagColor: ObsidianTheme.error,
                    ),
                    _buildLogCard(
                      icon: Icons.key,
                      iconColor: ObsidianTheme.onSurfaceVariant,
                      iconBgColor: ObsidianTheme.surfaceContainerHighest,
                      category: 'AUTH EVENT',
                      categoryColor: ObsidianTheme.onSurfaceVariant,
                      time: 'Oct 25, 2023 • 19:15',
                      title: 'Admin login successful from recognized device',
                      user: 'Elena Rodriguez',
                      tag: 'Info',
                      tagColor: ObsidianTheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Load Previous Logs'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
