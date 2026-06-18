import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/obsidian_theme.dart';
import '../components/pharmaq_card.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../providers/admin_provider.dart';

class MentorDashboardScreen extends ConsumerStatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  ConsumerState<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends ConsumerState<MentorDashboardScreen> {
  bool _isFetched = false;

  @override
  Widget build(BuildContext context) {
    final employeesAsync = _isFetched ? ref.watch(employeesProvider) : null;

    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: TopAppBar(
        title: 'PharmaQ Mentor',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: ObsidianTheme.primary),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mentor Control Center',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ObsidianTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Clinical Evaluation & Auditing Portal',
              style: TextStyle(
                color: ObsidianTheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // Metrics Row
            Row(
              children: [
                Expanded(
                  child: PharmaQCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.assignment, color: ObsidianTheme.tertiary, size: 24),
                        SizedBox(height: 12),
                        Text('12', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface)),
                        Text('Active Vivas', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PharmaQCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.verified_user, color: ObsidianTheme.primary, size: 24),
                        SizedBox(height: 12),
                        Text('92%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface)),
                        Text('Compliance', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'QUICK ACTIONS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: ObsidianTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.go('/dashboard'); // Go to employee view to take exam/test
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline),
                  SizedBox(width: 8),
                  Text('Open Exam Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.push('/mentor/add-question/details');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 8),
                  Text('Add Question to Bank'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.push('/mentor/qbank');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: ObsidianTheme.tertiary,
                side: const BorderSide(color: ObsidianTheme.tertiary),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note),
                  SizedBox(width: 8),
                  Text('Question Bank Editor'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Performance List
            const Text(
              'Employee Roster & Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ObsidianTheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            if (employeesAsync == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: PharmaQCard(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.people_outline, size: 48, color: ObsidianTheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      const Text(
                        'Roster is not loaded.',
                        style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _isFetched = true),
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text(
                            'Load Employee Roster',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              employeesAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator(color: ObsidianTheme.primary))),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: ObsidianTheme.error))),
                data: (employees) {
                if (employees.isEmpty) {
                  return const Center(child: Text('No employees logged in system.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    final String name = emp['name1'] ?? 'Staff Member';
                    final String initials = name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase();
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: PharmaQCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: ObsidianTheme.surfaceContainerHighest,
                              child: Text(
                                initials.isEmpty ? 'PM' : initials,
                                style: const TextStyle(color: ObsidianTheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: ObsidianTheme.onSurface)),
                                  Text(
                                    emp['designation'] ?? 'Pharmacist',
                                    style: const TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ObsidianTheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                emp['emp_id'] ?? '',
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: ObsidianTheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
