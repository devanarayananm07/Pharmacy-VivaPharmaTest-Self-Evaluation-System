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
          final List<dynamic> logs = data['logs'] ?? [];

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

                // 2. Bento Grid KPI Summary (Compact 4-column row)
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactKpiCard(
                        title: 'COMPLIANCE',
                        value: '$avgSystemScore%',
                        icon: Icons.donut_large_rounded,
                        color: ObsidianTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactKpiCard(
                        title: 'TOTAL VIVAS',
                        value: '${attempts.length}',
                        icon: Icons.assignment_turned_in_rounded,
                        color: ObsidianTheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactKpiCard(
                        title: 'QUESTIONS',
                        value: '${questions.length}',
                        icon: Icons.quiz_rounded,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactKpiCard(
                        title: 'ACTIVE STAFF',
                        value: '$totalActiveStaff',
                        icon: Icons.people_alt_rounded,
                        color: Colors.cyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Small Visualizations in Small Sections (Side-by-side compact charts)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildComplianceBreakdownCard(
                        compliant: compliantCount,
                        atRisk: atRiskCount,
                        nonCompliant: nonCompliantCount,
                        uncertified: uncertifiedCount,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStoreProficiencyCard(sortedStores),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Latest System Updates Table
                _buildSystemUpdatesFeed(logs),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return PharmaQCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: ObsidianTheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
    final List<double> values = [
      compliant.toDouble(),
      atRisk.toDouble(),
      nonCompliant.toDouble(),
      uncertified.toDouble(),
    ];
    final List<Color> colors = [
      ObsidianTheme.tertiary,
      Colors.orange,
      ObsidianTheme.error,
      ObsidianTheme.outline,
    ];

    return PharmaQCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'STAFF COMPLIANCE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: ObsidianTheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 75,
            height: 75,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(75, 75),
                  painter: DonutChartPainter(values: values, colors: colors),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ObsidianTheme.onSurface,
                      ),
                    ),
                    const Text(
                      'Staff',
                      style: TextStyle(
                        fontSize: 8,
                        color: ObsidianTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildLegendItem('Compliant', '$compliant', ObsidianTheme.tertiary),
          const SizedBox(height: 4),
          _buildLegendItem('At Risk', '$atRisk', Colors.orange),
          const SizedBox(height: 4),
          _buildLegendItem('Non-Compliant', '$nonCompliant', ObsidianTheme.error),
          const SizedBox(height: 4),
          _buildLegendItem('Uncertified', '$uncertified', ObsidianTheme.outline),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 9, color: ObsidianTheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStoreProficiencyCard(List<MapEntry<String, double>> sortedStores) {
    return PharmaQCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STORE PROFICIENCY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: ObsidianTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedStores.isEmpty)
            const SizedBox(
              height: 125,
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant),
                ),
              ),
            )
          else
            SizedBox(
              height: 125,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: sortedStores.take(4).map((entry) {
                  final store = entry.key;
                  final score = entry.value;
                  final color = score >= 80
                      ? ObsidianTheme.tertiary
                      : (score >= 60 ? Colors.orange : ObsidianTheme.error);
                  
                  String shortName = store;
                  if (store.toLowerCase().startsWith('main pharmacy ')) {
                    shortName = 'Phar ' + store.substring(14);
                  } else if (store.toLowerCase().startsWith('store ')) {
                    shortName = 'St ' + store.substring(6);
                  } else if (store.length > 7) {
                    shortName = store.substring(0, 5) + '..';
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${score.toInt()}%',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: 14,
                            height: 80,
                            decoration: BoxDecoration(
                              color: ObsidianTheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            width: 14,
                            height: 80 * (score / 100.0),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 40,
                        child: Text(
                          shortName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 8,
                            color: ObsidianTheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemUpdatesFeed(List<dynamic> logs) {
    final latestLogs = logs.take(5).toList();

    return PharmaQCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LATEST SYSTEM UPDATES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: ObsidianTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (latestLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text('No recent updates recorded.',
                    style: TextStyle(color: ObsidianTheme.onSurfaceVariant)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: latestLogs.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: ObsidianTheme.outlineVariant, height: 20),
              itemBuilder: (context, index) {
                final log = latestLogs[index];
                final String action = log['action'] ?? 'System update';
                final String user = log['user'] ?? 'System';
                final String type = log['type'] ?? 'info';
                final String dateTime = log['date'] ?? '';

                IconData icon;
                Color iconColor;
                if (type == 'question') {
                  icon = Icons.quiz_rounded;
                  iconColor = ObsidianTheme.primary;
                } else if (type == 'employee') {
                  icon = Icons.manage_accounts_rounded;
                  iconColor = ObsidianTheme.tertiary;
                } else {
                  icon = Icons.info_outline;
                  iconColor = ObsidianTheme.outline;
                }

                String timeDisplay = dateTime;
                if (dateTime.contains(' ')) {
                  final parts = dateTime.split(' ');
                  if (parts.length > 1) {
                    final timePart = parts[1];
                    timeDisplay = timePart.length >= 5 ? timePart.substring(0, 5) : timePart;
                  }
                }

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user,
                            style: const TextStyle(
                              fontSize: 10,
                              color: ObsidianTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeDisplay,
                      style: const TextStyle(
                        fontSize: 10,
                        color: ObsidianTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
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

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = values.fold(0, (sum, val) => sum + val);
    if (total == 0) {
      final paint = Paint()
        ..color = ObsidianTheme.surfaceContainerHighest
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8;
      canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 4, paint);
      return;
    }

    final double center = size.width / 2;
    final double radius = size.width / 2 - 5;
    final rect = Rect.fromCircle(center: Offset(center, center), radius: radius);

    double startAngle = -3.141592653589793 / 2; // Start from top
    int nonZeroCount = values.where((v) => v > 0).length;
    
    // If there is only one non-zero segment, don't use gaps
    final double gapAngle = nonZeroCount > 1 ? 0.08 : 0.0;

    for (int i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;
      final double sweepAngle = (values[i] / total) * 2 * 3.141592653589793;
      if (sweepAngle <= 0.001) continue;
      
      final double effectiveGap = (sweepAngle > gapAngle * 1.5) ? gapAngle : 0.0;
      final double drawStart = startAngle + effectiveGap / 2;
      final double drawSweep = sweepAngle - effectiveGap;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.butt;
      
      canvas.drawArc(rect, drawStart, drawSweep, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}

