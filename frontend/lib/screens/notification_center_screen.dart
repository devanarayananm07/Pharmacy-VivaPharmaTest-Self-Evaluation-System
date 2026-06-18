import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../components/pharmaq_card.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'PharmaQ', showBackButton: false, actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.settings, color: ObsidianTheme.onSurfaceVariant),
        )
      ]),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Mark all as read'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNotificationItem(
              icon: Icons.download,
              iconColor: ObsidianTheme.primary,
              iconBg: ObsidianTheme.primary.withValues(alpha: 0.1),
              title: 'Export Ready',
              time: '2m ago',
              description: 'Clinical Export 2023.xlsx is ready for download',
              actionWidget: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Download'),
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.sync,
              iconColor: ObsidianTheme.onSurfaceVariant,
              iconBg: ObsidianTheme.surfaceContainerHighest,
              title: 'Export in Progress',
              time: 'Active',
              description: 'Generating Cardiology Batch...',
              actionWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: ObsidianTheme.surfaceContainerHighest,
                    color: ObsidianTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('65% complete', style: TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant)),
                      Text('ETA 45s', style: TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.report,
              iconColor: ObsidianTheme.error,
              iconBg: ObsidianTheme.error.withValues(alpha: 0.2),
              title: 'Security Alert',
              time: '1h ago',
              description: 'New login from Chrome on Windows',
              actionWidget: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: ObsidianTheme.error,
                  side: const BorderSide(color: ObsidianTheme.error),
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('This wasn\'t me'),
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.track_changes,
              iconColor: ObsidianTheme.tertiary,
              iconBg: ObsidianTheme.tertiary.withValues(alpha: 0.1),
              title: 'Weekly Target',
              time: 'Yesterday',
              description: 'You are 42 questions away from your 150-question weekly goal.',
              actionWidget: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ObsidianTheme.surfaceContainerLowest,
                          border: Border.all(color: ObsidianTheme.outlineVariant.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PROGRESS', style: TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            Text('108/150', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ObsidianTheme.tertiary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ObsidianTheme.surfaceContainerLowest,
                          border: Border.all(color: ObsidianTheme.outlineVariant.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('STREAK', style: TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            Text('12 Days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Activity Overview
            Row(
              children: [
                Expanded(
                  child: PharmaQCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('WEEKLY INSIGHT', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                        const Text('Notification Volume', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (var h in [0.3, 0.5, 0.8, 0.6, 0.9, 0.4, 0.2])
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    height: 60 * h,
                                    decoration: BoxDecoration(
                                      color: h > 0.5 ? ObsidianTheme.primary : ObsidianTheme.outlineVariant,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PharmaQCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('STORAGE STATUS', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                        const Text('Cloud Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Used: 4.2 GB', style: TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant)),
                            Text('Total: 10 GB', style: TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.42,
                          backgroundColor: ObsidianTheme.surfaceContainerHighest,
                          color: ObsidianTheme.tertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ObsidianTheme.onSurfaceVariant,
                              side: const BorderSide(color: ObsidianTheme.outlineVariant),
                            ),
                            child: const Text('Manage Storage'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String time,
    required String description,
    Widget? actionWidget,
  }) {
    return PharmaQCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: const TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14, color: ObsidianTheme.onSurfaceVariant)),
                if (actionWidget != null) ...[
                  const SizedBox(height: 8),
                  actionWidget,
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
