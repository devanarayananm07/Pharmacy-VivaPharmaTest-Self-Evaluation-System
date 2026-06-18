import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/obsidian_theme.dart';
import '../components/glass_card.dart';
import '../components/mesh_background.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() async {
    final success = await ref.read(authProvider.notifier).login(
      _employeeIdController.text,
      _passwordController.text,
    );
    
    if (mounted) {
      if (success) {
        context.go('/dashboard');
      } else {
        final error = ref.read(authProvider).errorMessage ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: ObsidianTheme.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: MeshBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Branding Section
                  Icon(Icons.medical_information, size: 48, color: primary),
                  const SizedBox(height: 16),
                  Text(
                    'PharmaQ Login',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clinical Enterprise Portal',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Login GlassCard
                  GlassCard(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Employee ID Input
                        Text(
                          'EMPLOYEE ID',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _employeeIdController,
                          style: TextStyle(color: onSurface),
                          decoration: InputDecoration(
                            hintText: 'Enter your system ID',
                            prefixIcon: Icon(Icons.badge_outlined, color: onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Password Input
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PASSWORD',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Forgot?', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: onSurface),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Icon(Icons.lock_outline, color: onSurfaceVariant),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: onSurfaceVariant,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Login Button
                        SizedBox(
                          height: 52,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final authState = ref.watch(authProvider);
                              final isLoading = authState.status == AuthStatus.authenticating;
                              
                              return ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: theme.brightness == Brightness.dark
                                    ? const Color(0xFF0A0012)
                                    : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 8,
                                  shadowColor: primary.withValues(alpha: 0.2),
                                ),
                                child: isLoading 
                                  ? SizedBox(
                                      height: 24, width: 24,
                                      child: CircularProgressIndicator(
                                        color: theme.brightness == Brightness.dark
                                          ? ObsidianTheme.background
                                          : Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text('Authorize Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 20),
                                      ],
                                    ),
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Footer decorative elements
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMiniBadge(Icons.shield_outlined, 'SSL Active'),
                      const SizedBox(width: 16),
                      _buildMiniBadge(Icons.dns_outlined, 'Node Cluster-04'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Authorized medical personnel only. All access is logged and monitored per HIPAA compliance protocols.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: onSurfaceVariant, fontSize: 10, height: 1.5),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.secondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
