import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Real-time validation checks
  bool get _hasMinLength => _passController.text.length >= 8;
  bool get _hasNumber => _passController.text.contains(RegExp(r'\d'));
  bool get _hasSymbol => _passController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _hasUppercase => _passController.text.contains(RegExp(r'[A-Z]'));
  
  bool get _passwordsMatch => _passController.text.isNotEmpty && _passController.text == _confirmController.text;
  
  bool get _isValid => _hasMinLength && _hasNumber && _hasSymbol && _hasUppercase && _passwordsMatch;

  int get _strengthScore {
    if (_passController.text.isEmpty) return 0;
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasNumber) score++;
    if (_hasSymbol) score++;
    if (_hasUppercase) score++;
    return score;
  }

  String get _strengthLabel {
    if (_strengthScore <= 1) return 'Weak';
    if (_strengthScore <= 3) return 'Moderate';
    return 'Strong';
  }

  Color get _strengthColor {
    if (_strengthScore <= 1) return ObsidianTheme.error;
    if (_strengthScore <= 3) return ObsidianTheme.tertiary;
    return ObsidianTheme.primary;
  }

  Future<void> _handleSubmit() async {
    if (!_isValid) return;

    setState(() => _isLoading = true);
    
    try {
      await ref.read(authProvider.notifier).changePassword(_passController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!'), backgroundColor: ObsidianTheme.primary, behavior: SnackBarBehavior.floating),
        );
        // Navigate back to dashboard or home
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: ObsidianTheme.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final forcePasswordChange = ref.watch(authProvider.select((s) => s.forcePasswordChange));

    return PopScope(
      canPop: !forcePasswordChange,
      child: Scaffold(
        appBar: TopAppBar(
          title: 'PharmaQ',
          showBackButton: !forcePasswordChange, // Prevent going back during forced change
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ObsidianTheme.outlineVariant),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDqvIVbJ8l2nlVvqgsUD0JYQFD9ZE_Pwa2Js6aAzC9o8ud-erkEhFE1_ESvA6skwLIrojvwMxksLIwbTphVr_h_yxr3mUQ-Kpv52ZqwPcOXIMrT67YzgqK3kj9UVb0N4b-s_Pf2hLjbl1AnBU881WJIBkGoz5tEyhPlxls5uxYta6K8ewzQjs476WCXWgz-DYn2NZYyo_QO0NNYYxI00nLk6qQYhBl8oDo6sw0k0IZJ_p-cz62JQngxRwuz2uIvBBsl2HlGDQr-WqY'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: ObsidianTheme.surfaceContainer,
                    border: Border.all(color: ObsidianTheme.outlineVariant),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ObsidianTheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset, color: ObsidianTheme.primary, size: 28),
                      ),
                      const SizedBox(height: 16),
                      const Text('Secure Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        forcePasswordChange
                            ? 'First-time Login: Please set a new secure password before continuing.'
                            : 'Please set a new secure password to continue.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 14),
                      ),
                    const SizedBox(height: 32),

                    // Inputs
                    _buildLabel('NEW PASSWORD'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passController,
                      obscureText: _obscurePass,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.key, color: ObsidianTheme.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: ObsidianTheme.onSurfaceVariant),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                        hintText: '••••••••',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Dynamic Strength Indicator
                    Row(
                      children: [
                        Expanded(child: Container(height: 2, color: _strengthScore >= 1 ? _strengthColor : ObsidianTheme.surfaceContainerHighest)),
                        const SizedBox(width: 4),
                        Expanded(child: Container(height: 2, color: _strengthScore >= 3 ? _strengthColor : ObsidianTheme.surfaceContainerHighest)),
                        const SizedBox(width: 4),
                        Expanded(child: Container(height: 2, color: _strengthScore == 4 ? _strengthColor : ObsidianTheme.surfaceContainerHighest)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Password security: ${_passController.text.isEmpty ? "None" : _strengthLabel}', 
                        style: TextStyle(fontSize: 10, color: _passController.text.isEmpty ? ObsidianTheme.onSurfaceVariant : _strengthColor, fontWeight: FontWeight.w500)),
                    ),
                    
                    const SizedBox(height: 24),
                    _buildLabel('CONFIRM NEW PASSWORD'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.verified_user_outlined, color: ObsidianTheme.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: ObsidianTheme.onSurfaceVariant),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        hintText: '••••••••',
                        errorText: _confirmController.text.isNotEmpty && !_passwordsMatch ? 'Passwords do not match' : null,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    // Dynamic Requirements
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ObsidianTheme.surfaceContainerLowest,
                        border: Border.all(color: ObsidianTheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('REQUIREMENTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurfaceVariant, letterSpacing: 1.2)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildReq(Icons.check_circle, '8+ characters', _hasMinLength)),
                              Expanded(child: _buildReq(Icons.check_circle, '1+ symbol', _hasSymbol)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildReq(Icons.check_circle, '1+ number', _hasNumber)),
                              Expanded(child: _buildReq(Icons.check_circle, 'Uppercase letter', _hasUppercase)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isValid && !_isLoading ? _handleSubmit : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: ObsidianTheme.background, strokeWidth: 2))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Update Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                    ),
                    
                    const SizedBox(height: 32),
                    const Divider(color: ObsidianTheme.outlineVariant),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.support_agent, size: 18),
                      label: const Text('Need help with your account security?', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: ObsidianTheme.onSurfaceVariant),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('PHARMAQ SECURE PROTOCOL © 2024 • END-TO-END ENCRYPTED', style: TextStyle(fontSize: 10, color: ObsidianTheme.onSurfaceVariant, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ObsidianTheme.onSurfaceVariant, letterSpacing: 1.2)),
    );
  }

  Widget _buildReq(IconData icon, String text, bool isMet) {
    return Row(
      children: [
        Icon(isMet ? icon : Icons.circle_outlined, size: 14, color: isMet ? ObsidianTheme.primary : ObsidianTheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, color: isMet ? ObsidianTheme.primary : ObsidianTheme.onSurfaceVariant)),
      ],
    );
  }
}
