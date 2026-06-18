import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/pharmaq_card.dart';

class ExamDashboardScreen extends StatefulWidget {
  const ExamDashboardScreen({super.key});

  @override
  State<ExamDashboardScreen> createState() => _ExamDashboardScreenState();
}

class _ExamDashboardScreenState extends State<ExamDashboardScreen> {
  double _questionCount = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'PharmaQ',
        actions: [
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('Dashboard', style: TextStyle(color: ObsidianTheme.primary))),
              TextButton(onPressed: () {}, child: const Text('History', style: TextStyle(color: ObsidianTheme.onSurfaceVariant))),
              TextButton(onPressed: () {}, child: const Text('Resources', style: TextStyle(color: ObsidianTheme.onSurfaceVariant))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCWsz7U0-Ix9hw5NivXCYGd3jTAKdxSglHhMSrcZRQCE0slXH9CVk8brQ6nCtc-kqn3t_v3gElawsqImu8tCsjQ5s55MXm-TPdCTh0Wr_oP0IQywnk-Fpio41K4JHLc065PU_8Ij3OvgqckMgrpOenYV-QicCV8VIgK7Zzyen1NhfBbcDcXmmUiU0WYoHEBr_okjlktbi0vG-pJ-ctmfowIrhRAIvUEHLBcp_ymrDzrr8_nsVIdaf-gOtclXv5wMfTcZWMEwh-Wv1s'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Section
              const Text(
                'Welcome back, Dr. Aris.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your weekly performance is trending upwards. Complete your remaining 105 questions to stay ahead of the curve.',
                style: TextStyle(
                  fontSize: 14,
                  color: ObsidianTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Target Progress Card
              PharmaQCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WEEKLY TARGET',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: ObsidianTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                ),
                                children: [
                                  TextSpan(text: '45', style: TextStyle(color: ObsidianTheme.onSurface)),
                                  TextSpan(text: '/150', style: TextStyle(color: ObsidianTheme.outline)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.trending_up, color: ObsidianTheme.tertiary, size: 32),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.3,
                        backgroundColor: ObsidianTheme.surfaceContainerHighest,
                        color: ObsidianTheme.primary,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '30% Completed',
                          style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant),
                        ),
                        Text(
                          '105 Questions Remaining',
                          style: TextStyle(fontSize: 12, color: ObsidianTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Initialize New Viva Session
              PharmaQCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ObsidianTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.quiz, color: ObsidianTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Initialize New Viva Session',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ObsidianTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Selectors
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('SELECT STORE', 'Main Pharmacy A')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown('DEPARTMENT', 'Pharmacology')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown('DAY SCHEDULE', 'Full Week'),
                    const SizedBox(height: 32),

                    // Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'QUESTIONS PER SESSION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: ObsidianTheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _questionCount.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ObsidianTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: ObsidianTheme.primary,
                        inactiveTrackColor: ObsidianTheme.outlineVariant,
                        thumbColor: ObsidianTheme.primary,
                        trackHeight: 4.0,
                      ),
                      child: Slider(
                        value: _questionCount,
                        min: 5,
                        max: 50,
                        divisions: 45,
                        onChanged: (value) {
                          setState(() {
                            _questionCount = value;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('5 QNS', style: TextStyle(fontSize: 10, color: ObsidianTheme.outline)),
                        Text('50 QNS', style: TextStyle(fontSize: 10, color: ObsidianTheme.outline)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Start Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ObsidianTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Initialize Viva',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0a0012)),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Color(0xFF0a0012)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mini Stats
              Row(
                children: [
                  Expanded(child: _buildMiniStat(Icons.timer, ObsidianTheme.tertiary, 'Avg. Speed', '42s / Qn')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMiniStat(Icons.verified, ObsidianTheme.primary, 'Accuracy Rate', '88.4%')),
                ],
              ),
              const SizedBox(height: 16),

              // Recent Activity Table
              PharmaQCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LATEST SESSIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: ObsidianTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentSession('Clinical Pharmacy Viva', '14/15 Correct', ObsidianTheme.tertiary),
                    const Divider(color: ObsidianTheme.outlineVariant, height: 24),
                    _buildRecentSession('Pharmacology Quiz', '28/30 Correct', ObsidianTheme.tertiary),
                    const Divider(color: ObsidianTheme.outlineVariant, height: 24),
                    _buildRecentSession('General Therapeutics', '18/25 Correct', ObsidianTheme.error),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: ObsidianTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ObsidianTheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: ObsidianTheme.onSurface,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: ObsidianTheme.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, Color color, String title, String value) {
    return PharmaQCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSession(String name, String score, Color dotColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 14, color: ObsidianTheme.onSurface),
            ),
          ],
        ),
        Text(
          score,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: ObsidianTheme.outline,
          ),
        ),
      ],
    );
  }
}
