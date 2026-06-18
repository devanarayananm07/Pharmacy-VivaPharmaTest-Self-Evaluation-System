import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/pharmaq_card.dart';

class ComplianceReportingScreen extends StatelessWidget {
  const ComplianceReportingScreen({super.key});

  Widget _buildEmployeeCard({
    required String name,
    required String avatarUrl,
    required String status,
    required Color statusColor,
    required int progress,
    required int total,
    required Color dotColor,
    required String activeTime,
  }) {
    final progressRatio = progress / total;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: PharmaQCard(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ObsidianTheme.outlineVariant),
                image: DecorationImage(
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ObsidianTheme.onSurface,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Active $activeTime',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: ObsidianTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Progress: $progress/$total',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: ObsidianTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      backgroundColor: ObsidianTheme.surfaceContainerHighest,
                      color: statusColor,
                      minHeight: 6,
                    ),
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

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? ObsidianTheme.primary : ObsidianTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? ObsidianTheme.primary : ObsidianTheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : ObsidianTheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Compliance Overview',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCwJxuF3bSynpRROiilfwc21H3_P-z3YN6m_mHw0FXvIGtz84egQvyL9Z60MFs6irWTh07GS7fsq28Y5Ia05Tqy7ZMaUcFYcG13ekdC1qx3kCfHLZJaZwuPdHIOjarfYdgcbFicpFP4XHflWbFHbDAjqGetUwv8TvS79pVWOnQl35FsvHHoUJR3ZlAD7we1ZO1y3YpZHE8J8ZyHrvD4A016OdvTj_JFKzc1crWjrnOVHzxgnumYOxgPtjR7JbmWy9dN0Us4AnJokpY'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Global Compliance Circle
              PharmaQCard(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: 0.78,
                            strokeWidth: 12,
                            backgroundColor: ObsidianTheme.outlineVariant,
                            color: ObsidianTheme.primary,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '78%',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: ObsidianTheme.onSurface,
                              ),
                            ),
                            Text(
                              'ON TRACK',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ObsidianTheme.onSurfaceVariant,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Global Compliance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ObsidianTheme.onSurface,
                      ),
                    ),
                    const Text(
                      'Overall team performance this period',
                      style: TextStyle(
                        fontSize: 14,
                        color: ObsidianTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Weekly Stats & Summary
              PharmaQCard(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'COLLECTIVE TARGET',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ObsidianTheme.onSurfaceVariant,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.trending_up, size: 16, color: ObsidianTheme.tertiary),
                            const SizedBox(width: 4),
                            Text(
                              '+12% vs LW',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ObsidianTheme.tertiary,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '4,250',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: ObsidianTheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ 6,000',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: ObsidianTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Questions answered across all managed teams.',
                      style: TextStyle(
                        fontSize: 14,
                        color: ObsidianTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress to Goal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ObsidianTheme.onSurfaceVariant,
                          ),
                        ),
                        const Text(
                          '70.8%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ObsidianTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.708,
                        backgroundColor: ObsidianTheme.surfaceContainerHighest,
                        color: ObsidianTheme.primary,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Filters Section
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Members', isSelected: true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Compliant'),
                    const SizedBox(width: 8),
                    _buildFilterChip('At Risk'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Non-Compliant'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Employee List Section
              Text(
                'MANAGED EMPLOYEES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.onSurfaceVariant,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildEmployeeCard(
                name: 'Alex Rivera',
                avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDzrvoHQooUsp3CDdZKgbjEVN3c9Yn0R20nZGIBbyTMOOCfLKPcLKzZ5keIzIDvpyzeFcnTCnEzSsPjri12isuuxdPvsqIwni0i7AjhcwYDqzHxRprE1cd7rfNamqHCKbptMp0V7QFzqiZgcUcYxbjpkN2UCU55ZQmPYBS0ukp_6ucyf4mTdVhkA21EHVYTB0AF7hBwKpbTA3xJOhFOftEjIELYCjil34lh6LFSU1O0c4Gt2JdeGNaJ6iXYkGQgmS7A6Rc4Rs6yphY',
                status: 'Compliant',
                statusColor: ObsidianTheme.tertiary,
                progress: 142,
                total: 150,
                dotColor: ObsidianTheme.tertiary,
                activeTime: '2h ago',
              ),
              _buildEmployeeCard(
                name: 'Sarah Chen',
                avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCh6AXnuyCA0GLNFIizketZKmiYxGLVfRCYSAFTin3YNhtpzrxO4vMkvluWvNV1yxquOUBg9eglh27bscPX_jsXoU6n_0jKxHSWTkTklIGkOF8vTJYkxANBz7f3s2O09dLoEu8Bn1u8m-wfW-_i6xde9xoz3_zehvZmUOvxIKT_TRS-D2zm_cH-xisWORn_xBiezvWQdGh-KlM9QVHKRd4t2Fsr6hF0NkaVbCV3GELwtQHbFrmI_5Som3BwUDC4GdV_uUoWwIY7eNc',
                status: 'At Risk',
                statusColor: Colors.orange,
                progress: 112,
                total: 150,
                dotColor: Colors.orange,
                activeTime: '4h ago',
              ),
              _buildEmployeeCard(
                name: 'Marcus Thorne',
                avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAJ9qBKaLYsp59PKxPQ8--Rkjfhp16VQov7IGKlR8rot1Nll9hgkZDCng_RIQs-aVRAJlGnAEk5Zu0g_4Riaty07WVbbd_QbK_roOc-a668FTowJzkEIYVogE-iYSi2Os89df1HNP4OJceZvzSaCG2RXyH-VJqLaMSCHwM6qevlSWRZ1yRbioVyzevZRXj4EbIt3lzIYORwxZaPZBNUjaq_wxfwiCRH8EMs_8Uh3uZpo-f9hgHmBZYfDHDsNpY8uTFQNtxMIgpcAKA',
                status: 'Non-Compliant',
                statusColor: ObsidianTheme.error,
                progress: 45,
                total: 150,
                dotColor: ObsidianTheme.error,
                activeTime: '1d ago',
              ),
              _buildEmployeeCard(
                name: 'Elena Vance',
                avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXG72KNT4xqD2aUrjjk9-oGGi7l9r2xzUe97YOqvTe2SBhiaiB8UPfgfDkrxWA9ZLw3XlZYJJR45s3JLoD8YCL0_lwQxnPAGDQgyG97kNV3yFRfMTO4dExxExXTz_v44gbbw8DZQqBGcxdUEIzsi8afdzMSIogU5kyl4VGRuCjJTwYvXjh_xxVaB5YUGmTIxx-veP4IXks2qVSyyPGO5jHr1_rSQQ5vYFHCeZAUqT91fHaV8Ctz29lAdIxwC-ge6dY9y6B8vhGAgE',
                status: 'Compliant',
                statusColor: ObsidianTheme.tertiary,
                progress: 150,
                total: 150,
                dotColor: ObsidianTheme.tertiary,
                activeTime: '15m ago',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
