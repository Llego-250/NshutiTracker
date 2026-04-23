import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/providers.dart';
import 'main_shell.dart';
import 'signup_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email first.');
      return;
    }
    try {
      await ref.read(authServiceProvider).sendPasswordReset(_emailCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0F1A), Color(0xFF1A0D2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.favorite, color: accentPink, size: 36),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (b) => btnGradient.createShader(b),
                  child: const Text('NshutiTrack',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 6),
                const Text('RECONNECT. TOGETHER.',
                    style: TextStyle(color: textSecondary, letterSpacing: 2, fontSize: 12)),
                const SizedBox(height: 40),
                _label('EMAIL ADDRESS'),
                const SizedBox(height: 8),
                _field(controller: _emailCtrl, hint: 'hello@nshuti.love', icon: Icons.email_outlined),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _label('PASSWORD'),
                    TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('Forgot Password?',
                          style: TextStyle(color: textSecondary, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _field(
                  controller: _passCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: textSecondary, size: 18),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: accentPink, fontSize: 12)),
                ],
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _loading ? null : _submit,
                  child: Container(
                    width: double.infinity, height: 54,
                    decoration: BoxDecoration(
                        gradient: btnGradient, borderRadius: BorderRadius.circular(30)),
                    alignment: Alignment.center,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Sign In to Bond',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New to the journey? ', style: TextStyle(color: textSecondary)),
                      Text('Create Account', style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  '"where technology meets the heartbeat of your most cherished relationships."',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSecondary, fontSize: 11, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: textSecondary, fontSize: 11, letterSpacing: 1.5)),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) =>
      Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF2A2D3E)))),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: textSecondary),
            prefixIcon: Icon(icon, color: textSecondary, size: 18),
            suffixIcon: suffix,
            border: InputBorder.none,
          ),
        ),
      );
}
