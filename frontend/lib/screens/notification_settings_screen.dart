import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../components/pharmaq_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool pushEnabled = true;
  bool exportReady = true;
  bool exportProgress = false;
  bool newLogin = true;
  bool passChange = true;
  bool weeklyTarget = true;
  bool perfMilestones = false;
  String deliveryMethod = 'push';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'PharmaQ',
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDJv8X4-ImUUz1T5SvtErcXjLbRVdYBRLEyKibyPdDkdRnOlw0lh9oJqjbuRRYhrKg5FlTN7vRByar3IpIxYud1cF3Nt1Lts9AUAfK8-O_zMkCoNNAJm6rA6v37eWHO0JRakDhva6hFjKwQN4NtCaruKINWxlUkSqy4XEVkiDfO5Qfvq_gkBaSkRQXrvx_mrf7WGII3lkBjstc3NEzfXzTR9B43AfYwm-NoYZ4ikofeNBtau4Jthm7WGxL-W8TG-6P9EPZo1iLbyT8'),
            ),
          )
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2), // Profile/Logs context
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, size: 14, color: ObsidianTheme.onSurfaceVariant),
                SizedBox(width: 4),
                Text('SYSTEM SETTINGS', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Notification Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Manage how and when you receive clinical updates and account alerts.', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 14)),
            const SizedBox(height: 24),
            
            // Global Push
            PharmaQCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: ObsidianTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.notifications_active, color: ObsidianTheme.primary),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Enable all system alerts on this device', style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Switch(
                    value: pushEnabled,
                    activeThumbColor: ObsidianTheme.primary,
                    onChanged: (v) => setState(() => pushEnabled = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(Icons.storage, 'CLINICAL EXPORTS', ObsidianTheme.tertiary),
            _buildToggleRow('Export Ready', 'Notify when report generation is complete', exportReady, (v) => setState(() => exportReady = v)),
            _buildToggleRow('Export in Progress', 'Real-time status of heavy data processing', exportProgress, (v) => setState(() => exportProgress = v)),
            const SizedBox(height: 24),

            _buildSectionHeader(Icons.security, 'ACCOUNT & SECURITY', ObsidianTheme.error),
            _buildToggleRow('New Login Alerts', 'Immediate alert for any new device login', newLogin, (v) => setState(() => newLogin = v)),
            _buildToggleRow('Password Change', 'Confirmations for credential updates', passChange, (v) => setState(() => passChange = v)),
            const SizedBox(height: 24),

            _buildSectionHeader(Icons.verified, 'COMPLIANCE & GOALS', ObsidianTheme.primary),
            _buildToggleRow('Weekly Target Reminders', 'Goal: 150-question clinical cycle', weeklyTarget, (v) => setState(() => weeklyTarget = v)),
            _buildToggleRow('Performance Milestones', 'Recognition of scoring achievements', perfMilestones, (v) => setState(() => perfMilestones = v)),
            const SizedBox(height: 24),

            _buildSectionHeader(Icons.mail, 'NOTIFICATION METHOD', ObsidianTheme.onSurfaceVariant),
            Row(
              children: [
                Expanded(child: _buildMethodSelector('smartphone', 'Push', 'push')),
                const SizedBox(width: 8),
                Expanded(child: _buildMethodSelector('alternate_email', 'Email', 'email')),
                const SizedBox(width: 8),
                Expanded(child: _buildMethodSelector('inbox', 'In-App', 'in-app')),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Discard', style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceContainerLowest,
        border: Border.all(color: ObsidianTheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant)),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: ObsidianTheme.primary,
        checkColor: ObsidianTheme.background,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildMethodSelector(String iconName, String label, String methodValue) {
    bool isSelected = deliveryMethod == methodValue;
    return GestureDetector(
      onTap: () => setState(() => deliveryMethod = methodValue),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? ObsidianTheme.primary.withValues(alpha: 0.05) : ObsidianTheme.surfaceContainer,
          border: Border.all(color: isSelected ? ObsidianTheme.primary : ObsidianTheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              iconName == 'smartphone' ? Icons.smartphone : (iconName == 'alternate_email' ? Icons.alternate_email : Icons.inbox),
              color: isSelected ? ObsidianTheme.primary : ObsidianTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? ObsidianTheme.primary : ObsidianTheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
