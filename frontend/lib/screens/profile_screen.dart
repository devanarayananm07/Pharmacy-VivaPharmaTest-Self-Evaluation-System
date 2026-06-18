import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../components/profile_avatar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final List<String> _maleAvatars = [
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=256', // Male Pharmacist/Doctor
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=256', // Male Specialist/Professional
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=256', // Male Portrait
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=256', // Male smiling portrait
    'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=256', // Male Executive
  ];

  final List<String> _femaleAvatars = [
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=256', // Female Pharmacist/Professional
    'https://images.unsplash.com/photo-1594824813573-246434de83fb?auto=format&fit=crop&q=80&w=256', // Female doctor/clinical scientist
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=256', // Female portrait
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=256', // Female with glasses
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&q=80&w=256', // Female portrait clinical
  ];

  void _saveAvatar(String url) {
    ref.read(profileAvatarProvider.notifier).setAvatar(url);
  }


  void _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  void _showAvatarPicker() {
    final selectedAvatar = ref.read(profileAvatarProvider);
    final textController = TextEditingController(text: selectedAvatar);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Select Profile Picture', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose one of our professional avatars:', style: TextStyle(fontSize: 13, color: ObsidianTheme.onSurfaceVariant)),
                const SizedBox(height: 20),
                
                // Men's Variety Header
                const Text('MEN\'S VARIETY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _maleAvatars.map((url) {
                    final isSel = selectedAvatar == url;
                    return GestureDetector(
                      onTap: () {
                        _saveAvatar(url);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? ObsidianTheme.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(url),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 20),
                
                // Women's Variety Header
                const Text('WOMEN\'S VARIETY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: ObsidianTheme.onSurfaceVariant)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _femaleAvatars.map((url) {
                    final isSel = selectedAvatar == url;
                    return GestureDetector(
                      onTap: () {
                        _saveAvatar(url);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? ObsidianTheme.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(url),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                const Divider(color: ObsidianTheme.outlineVariant),
                const SizedBox(height: 12),
                const Text('Or paste a custom image URL:', style: TextStyle(fontSize: 13, color: ObsidianTheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com/avatar.jpg',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  _saveAvatar(textController.text.trim());
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help & Support Center',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'PharmaQ Pharmacy Knowledge Evaluation Platform support coordinates:',
                style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildHelpRow(Icons.email_outlined, 'Email Support', 'support@amrita.edu'),
              const SizedBox(height: 16),
              _buildHelpRow(Icons.phone_outlined, 'Academic Helpline', '+91 484 285 1234'),
              const SizedBox(height: 16),
              _buildHelpRow(Icons.schedule_outlined, 'Availability', 'Mon - Sat: 9:00 AM - 5:00 PM'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: ObsidianTheme.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const TopAppBar(
        title: 'PharmaQ',
        showBackButton: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ProfileAvatar(radius: 16),
          )
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3), // Profile is index 3
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [ObsidianTheme.primary, ObsidianTheme.tertiary]),
                          ),
                          child: const ProfileAvatar(radius: 44),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: ObsidianTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 12, color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(authState.employeeName ?? 'Pharmacy Staff', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(authState.designation ?? 'Clinical Pharmacist', style: const TextStyle(color: ObsidianTheme.primary, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(authState.role?.toUpperCase() ?? 'EMPLOYEE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurfaceVariant)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.storefront, size: 16, color: ObsidianTheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(authState.workArea ?? 'Main Pharmacy A', style: const TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('ACCOUNT & PREFERENCES'),
                  _buildSettingsGroup([
                    _buildSettingsTile(Icons.lock_outline, 'Change Password', trailing: const Icon(Icons.chevron_right, color: ObsidianTheme.onSurfaceVariant), onTap: () {
                      context.push('/reset-password');
                    }),
                    _buildSettingsTile(
                      Icons.dark_mode_outlined, 
                      'Dark Theme Mode', 
                      trailing: Switch(
                        value: isDark, 
                        onChanged: (val) {
                          ref.read(themeModeProvider.notifier).toggleTheme(val);
                        },
                        activeThumbColor: ObsidianTheme.primary,
                      ),
                    ),
                    _buildSettingsTile(Icons.camera_alt_outlined, 'Change Profile Photo', trailing: const Icon(Icons.chevron_right, color: ObsidianTheme.onSurfaceVariant), onTap: _showAvatarPicker),
                  ]),
                  
                  if (authState.role == 'Admin' || authState.role == 'Mentor') ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('MANAGEMENT TOOLS'),
                    _buildSettingsGroup([
                      if (authState.role == 'Admin')
                        _buildSettingsTile(
                          Icons.people_outline, 
                          'Employee List Management', 
                          trailing: const Icon(Icons.chevron_right, color: ObsidianTheme.onSurfaceVariant), 
                          onTap: () => context.push('/admin/roles'),
                        ),
                      _buildSettingsTile(
                        Icons.quiz_outlined, 
                        'Question Management', 
                        trailing: const Icon(Icons.chevron_right, color: ObsidianTheme.onSurfaceVariant), 
                        onTap: () => context.push('/mentor/qbank'),
                      ),
                    ]),
                  ],
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('SUPPORT'),
                  _buildSettingsGroup([
                    _buildSettingsTile(Icons.help_outline, 'Help Center', iconColor: ObsidianTheme.onSurfaceVariant, trailing: const Icon(Icons.chevron_right, color: ObsidianTheme.onSurfaceVariant), onTap: _showHelpCenter),
                  ]),
                  
                  const SizedBox(height: 32),
                  // Logout Button
                  OutlinedButton(
                    onPressed: _handleLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ObsidianTheme.error,
                      side: const BorderSide(color: Color(0x4DDC2626)),
                      backgroundColor: const Color(0x1ADC2626),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Icon(Icons.logout),
                         SizedBox(width: 8),
                         Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text('PHARMAQ V2.4.0 (PRO)', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: ObsidianTheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          return Column(
            children: [
              child,
              if (idx < children.length - 1)
                Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outlineVariant, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {Widget? trailing, Color iconColor = ObsidianTheme.primary, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
