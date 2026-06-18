import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/mesh_background.dart';
import '../components/glass_card.dart';

class PushNotificationExportScreen extends StatelessWidget {
  const PushNotificationExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Export Status'),
      body: MeshBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: ObsidianTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ObsidianTheme.primary.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.check_circle_outline, color: ObsidianTheme.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PharmaQ System', style: TextStyle(color: ObsidianTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                            const Text('Export Complete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: ObsidianTheme.onSurface)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 16, height: 1.5),
                      children: [
                        TextSpan(text: 'Your clinical data export for '),
                        TextSpan(text: 'Antibiotics', style: TextStyle(color: ObsidianTheme.onSurface, fontWeight: FontWeight.bold)),
                        TextSpan(text: ' is ready '),
                        TextSpan(text: '(4.2 MB)', style: TextStyle(color: ObsidianTheme.tertiary, fontWeight: FontWeight.bold)),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Downloading file...')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ObsidianTheme.primary,
                            foregroundColor: const Color(0xFF0A0012),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Download Now', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ObsidianTheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: ObsidianTheme.outlineVariant),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
