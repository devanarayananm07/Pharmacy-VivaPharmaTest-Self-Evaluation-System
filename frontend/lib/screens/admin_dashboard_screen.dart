import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../components/pharmaq_card.dart';
import '../components/profile_avatar.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboardDataAsync = ref.watch(adminDashboardDataProvider);

    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: const TopAppBar(
        title: 'PharmaQ Admin',
        showBackButton: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ProfileAvatar(radius: 16),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: dashboardDataAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: ObsidianTheme.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: ObsidianTheme.error, size: 48),
                const SizedBox(height: 16),
                Text('Error loading admin dashboard: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: ObsidianTheme.error)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(adminDashboardDataProvider),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
        data: (data) {
          final List<dynamic> attempts = data['attempts'] ?? [];
          final List<dynamic> employees = data['employees'] ?? [];
          final List<dynamic> questions = data['questions'] ?? [];

          // 1. Calculations
          final completedAttempts = attempts.where((a) => a['status'] == 'Completed').toList();
          
          double sumScore = 0.0;
          for (var a in completedAttempts) {
            sumScore += (a['percent'] as num).toDouble();
          }
          final double avgSystemScore = completedAttempts.isNotEmpty
              ? double.parse((sumScore / completedAttempts.length).toStringAsFixed(1))
              : 0.0;

          // Group employees by compliance status
          final employeeScores = <String, List<double>>{};
          for (var a in completedAttempts) {
            final empId = a['employee_id']?.toString() ?? '';
            final pct = (a['percent'] as num).toDouble();
            employeeScores.putIfAbsent(empId, () => []).add(pct);
          }

          int compliantCount = 0;
          int atRiskCount = 0;
          int nonCompliantCount = 0;

          employeeScores.forEach((empId, scores) {
            final avg = scores.reduce((a, b) => a + b) / scores.length;
            if (avg >= 80) {
              compliantCount++;
            } else if (avg >= 60) {
              atRiskCount++;
            } else {
              nonCompliantCount++;
            }
          });

          // Uncertified registered employees (registered but no completed vivas yet)
          final activeEmpIds = employeeScores.keys.toSet();
          int uncertifiedCount = 0;
          for (var emp in employees) {
            final empId = emp['emp_id']?.toString() ?? '';
            if (emp['role'] == 'Employee' && !activeEmpIds.contains(empId)) {
              uncertifiedCount++;
            }
          }

          final int totalActiveStaff = employeeScores.length + uncertifiedCount;

          // Group attempts by store
          final storePerformance = <String, List<double>>{};
          for (var a in completedAttempts) {
            final store = a['store']?.toString().trim() ?? 'General';
            if (store.isNotEmpty) {
              final pct = (a['percent'] as num).toDouble();
              storePerformance.putIfAbsent(store, () => []).add(pct);
            }
          }

          final storeAverages = <String, double>{};
          storePerformance.forEach((store, scores) {
            final avg = scores.reduce((a, b) => a + b) / scores.length;
            storeAverages[store] = double.parse(avg.toStringAsFixed(1));
          });
          final sortedStores = storeAverages.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome and Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Analytics',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-time compliance monitoring & assessment activity',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Bento Grid KPI Summary
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildKpiCard(
                      title: 'AVG. COMPLIANCE',
                      value: '$avgSystemScore%',
                      icon: Icons.donut_large_rounded,
                      color: ObsidianTheme.primary,
                      subtitle: '${completedAttempts.length} exams reviewed',
                    ),
                    _buildKpiCard(
                      title: 'TOTAL VIVAS',
                      value: '${attempts.length}',
                      icon: Icons.assignment_turned_in_rounded,
                      color: ObsidianTheme.tertiary,
                      subtitle: '${completedAttempts.length} Completed • ${attempts.length - completedAttempts.length} In-Progress',
                    ),
                    _buildKpiCard(
                      title: 'QUESTION BANK',
                      value: '${questions.length}',
                      icon: Icons.quiz_rounded,
                      color: Colors.amber,
                      subtitle: 'Active clinical items',
                    ),
                    _buildKpiCard(
                      title: 'ACTIVE STAFF',
                      value: '$totalActiveStaff',
                      icon: Icons.people_alt_rounded,
                      color: Colors.cyan,
                      subtitle: '$compliantCount certified compliant',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Stacked Horizontal Compliance Bar
                _buildComplianceBreakdownCard(
                  compliant: compliantCount,
                  atRisk: atRiskCount,
                  nonCompliant: nonCompliantCount,
                  uncertified: uncertifiedCount,
                ),
                const SizedBox(height: 20),

                // 4. Store Proficiency Analysis
                _buildStoreProficiencyCard(sortedStores),
                const SizedBox(height: 20),

                // 5. Admin Quick Actions
                _buildQuickActionsCard(context),
                const SizedBox(height: 20),

                // 6. Recent Vivas Activity Table
                _buildRecentVivasFeed(completedAttempts, employees),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return PharmaQCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: ObsidianTheme.onSurfaceVariant,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9,
                  color: ObsidianTheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildComplianceBreakdownCard({
    required int compliant,
    required int atRisk,
    required int nonCompliant,
    required int uncertified,
  }) {
    final int total = compliant + atRisk + nonCompliant + uncertified;
    final double pctCompliant = total > 0 ? (compliant / total) : 0.0;
    final double pctAtRisk = total > 0 ? (atRisk / total) : 0.0;
    final double pctNonCompliant = total > 0 ? (nonCompliant / total) : 0.0;
    final double pctUncertified = total > 0 ? (uncertified / total) : 0.0;

    return PharmaQCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STAFF COMPLIANCE STATUS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: ObsidianTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Stacked Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  if (compliant > 0)
                    Expanded(
                      flex: (pctCompliant * 100).round(),
                      child: Container(color: ObsidianTheme.tertiary),
                    ),
                  if (atRisk > 0)
                    Expanded(
                      flex: (pctAtRisk * 100).round(),
                      child: Container(color: Colors.orange),
                    ),
                  if (nonCompliant > 0)
                    Expanded(
                      flex: (pctNonCompliant * 100).round(),
                      child: Container(color: ObsidianTheme.error),
                    ),
                  if (uncertified > 0)
                    Expanded(
                      flex: (pctUncertified * 100).round(),
                      child: Container(color: ObsidianTheme.outline),
                    ),
                  if (total == 0)
                    Expanded(
                      child: Container(color: ObsidianTheme.outlineVariant),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(
                  'Compliant (>=80%)', '$compliant', ObsidianTheme.tertiary),
              _buildLegendItem('At Risk (60-79%)', '$atRisk', Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(
                  'Non-Compliant (<60%)', '$nonCompliant', ObsidianTheme.error),
              _buildLegendItem('Uncertified (No Vivas)', '$uncertified', ObsidianTheme.outline),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: ObsidianTheme.onSurfaceVariant),
        ),
        Text(
          count,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStoreProficiencyCard(List<MapEntry<String, double>> sortedStores) {
    return PharmaQCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STORE CLINICAL PROFICIENCY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: ObsidianTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedStores.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                  child: Text('No store assessment data available',
                      style: TextStyle(color: ObsidianTheme.onSurfaceVariant))),
            )
          else
            ...sortedStores.map((entry) {
              final store = entry.key;
              final score = entry.value;
              final color = score >= 80
                  ? ObsidianTheme.tertiary
                  : (score >= 60 ? Colors.orange : ObsidianTheme.error);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(store,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                        Text('$score%',
                            style: TextStyle(
                                fontSize: 13,
                                color: color,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: score / 100.0,
                        backgroundColor: ObsidianTheme.surfaceContainerHighest,
                        color: color,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return PharmaQCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SYSTEM QUICK ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: ObsidianTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.people_outline,
                  label: 'Manage Roles',
                  onTap: () => context.push('/admin/roles'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Audit Logs',
                  onTap: () => context.push('/admin/audit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.assignment_outlined,
                  label: 'Compliance Report',
                  onTap: () => context.push('/admin/compliance'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: ObsidianTheme.surfaceContainer,
          border: Border.all(color: ObsidianTheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: ObsidianTheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentVivasFeed(List<dynamic> completedAttempts, List<dynamic> employees) {
    // Resolve employee names
    final Map<String, String> employeeNames = {};
    for (var emp in employees) {
      final id = emp['emp_id']?.toString() ?? '';
      final name = emp['name1']?.toString() ?? 'Staff Member';
      employeeNames[id] = name;
    }

    final latestCompleted = completedAttempts.take(5).toList();

    return PharmaQCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LATEST SYSTEM VIVAS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: ObsidianTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (latestCompleted.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text('No completed vivas recorded yet.',
                    style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: latestCompleted.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: ObsidianTheme.outlineVariant, height: 20),
              itemBuilder: (context, index) {
                final attempt = latestCompleted[index];
                final empId = attempt['employee_id']?.toString() ?? '';
                final name = employeeNames[empId] ?? empId;
                final score = (attempt['percent'] as num).toDouble();
                final store = attempt['store']?.toString() ?? 'General';
                final isPassed = (attempt['passed'] as num).toInt() == 1;

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? ObsidianTheme.tertiary.withValues(alpha: 0.1)
                            : ObsidianTheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPassed ? Icons.check : Icons.close,
                        color: isPassed ? ObsidianTheme.tertiary : ObsidianTheme.error,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            store,
                            style: const TextStyle(
                              fontSize: 10,
                              color: ObsidianTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$score%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? ObsidianTheme.tertiary : ObsidianTheme.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          attempt['date']?.toString().split(' ').first ?? '',
                          style: const TextStyle(
                            fontSize: 9,
                            color: ObsidianTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
