import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/providers.dart';
import 'main_shell.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});
  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signUp(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
        _nameCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
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
                const SizedBox(height: 48),
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.favorite, color: accentPink, size: 36),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (b) => btnGradient.createShader(b),
                  child: const Text('Create Account',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 6),
                const Text('JOIN THE JOURNEY',
                    style: TextStyle(color: textSecondary, letterSpacing: 2, fontSize: 12)),
                const SizedBox(height: 36),
                _label('YOUR NAME'),
                const SizedBox(height: 8),
                _field(controller: _nameCtrl, hint: 'Solide Aze', icon: Icons.person_outline),
                const SizedBox(height: 20),
                _label('EMAIL ADDRESS'),
                const SizedBox(height: 8),
                _field(controller: _emailCtrl, hint: 'hello@nshuti.love', icon: Icons.email_outlined),
                const SizedBox(height: 20),
                _label('PASSWORD'),
                const SizedBox(height: 8),
                _field(
                  controller: _passCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: _obscurePass,
                  suffix: IconButton(
                    icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility,
                        color: textSecondary, size: 18),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                const SizedBox(height: 20),
                _label('CONFIRM PASSWORD'),
                const SizedBox(height: 8),
                _field(
                  controller: _confirmPassCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: textSecondary, size: 18),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
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
                    decoration: BoxDecoration(gradient: btnGradient, borderRadius: BorderRadius.circular(30)),
                    alignment: Alignment.center,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Create Account',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: TextStyle(color: textSecondary)),
                      Text('Sign In', style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
