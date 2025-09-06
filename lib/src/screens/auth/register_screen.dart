import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _working = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _working = true);
    try {
      await context.read<AuthProvider>().signUpWithEmail(_email.text.trim(), _pass.text);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
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
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8))],
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(color: const Color(0xFFE6F5F3), borderRadius: BorderRadius.circular(18)),
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
            Text('Create Account',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF0A7B70))),
            const SizedBox(height: 6),
            Text('Join StatGenie today', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),

            _filledField(context, controller: _email, hint: 'Email', prefix: const Icon(Icons.mail_outlined, color: Color(0xFF0A7B70)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter email';
                  final ok = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);
                  return ok ? null : 'Invalid email';
                }),
            const SizedBox(height: 14),
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
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 14),
            _filledField(
              context,
              controller: _confirm,
              hint: 'Confirm Password',
              prefix: const Icon(Icons.lock_outline, color: Color(0xFF0A7B70)),
              obscure: true,
              validator: (v) => (v != _pass.text) ? 'Passwords do not match' : null,
            ),

            const SizedBox(height: 20),
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
                    : Text('Register', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.go('/auth/login'),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 14),
                  children: const [
                    TextSpan(text: "Already have an account? "),
                    TextSpan(text: "Log In", style: TextStyle(color: Color(0xFF0A7B70), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
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
}