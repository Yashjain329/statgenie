import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _working = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _working = true);
    try {
      await context.read<AuthProvider>().signInWithEmail(_email.text.trim(), _pass.text);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grad = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF10B7A3), Color(0xFF0A7B70)],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: grad),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _card(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Logo instead of lock
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F5F3),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/Logo.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.bar_chart_rounded, color: Color(0xFF0A7B70), size: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text('Welcome Back',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF0A7B70))),
            const SizedBox(height: 6),
            Text('Sign in to continue',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),

            // Email
            _filledField(
              context,
              controller: _email,
              hint: 'Email',
              prefix: const Icon(Icons.mail_outlined, color: Color(0xFF0A7B70)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter email';
                final ok = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);
                return ok ? null : 'Invalid email';
              },
            ),
            const SizedBox(height: 14),

            // Password
            _filledField(
              context,
              controller: _pass,
              hint: 'Password',
              prefix: const Icon(Icons.lock_outline, color: Color(0xFF0A7B70)),
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF0A7B70)),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/auth/forgot-password'),
                child: Text('Forgot Password?', style: GoogleFonts.inter(color: const Color(0xFF0A7B70), fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 6),

            // Log In button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _working ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A7B70),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 6,
                  shadowColor: const Color(0xFF0A7B70).withOpacity(0.4),
                ),
                child: _working
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Log In', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
              ),
            ),

            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => context.go('/auth/register'),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 14),
                  children: const [
                    TextSpan(text: "Don't have an account? "),
                    TextSpan(text: "Register", style: TextStyle(color: Color(0xFF0A7B70), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or continue with', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500)),
                ),
                Expanded(child: Divider(color: Colors.grey, thickness: 1)),
              ],
            ),
            const SizedBox(height: 14),

            // Social buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _circleSocial(
                  context,
                  icon: Image.asset('assets/icons/google.png', width: 22, height: 22, errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 28, color: Colors.red)),
                  glow: const Color(0xFFFF6B6B),
                  onTap: () => context.read<AuthProvider>().signInWithGoogle(),
                ),
                const SizedBox(width: 26),
                _circleSocial(
                  context,
                  icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
                  glow: const Color(0xFF1877F2),
                  onTap: () => context.read<AuthProvider>().signInWithFacebook(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filledField(
      BuildContext context, {
        required TextEditingController controller,
        required String hint,
        Widget? prefix,
        Widget? suffix,
        bool obscure = false,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFEAF6F4),
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB7D9D5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0A7B70), width: 1.6),
        ),
      ),
    );
  }

  Widget _circleSocial(BuildContext context, {required Widget icon, required Color glow, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: glow.withOpacity(0.25), blurRadius: 16, spreadRadius: 2),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}