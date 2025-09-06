import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _working = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _working = true);
    try {
      await context.read<AuthProvider>().resetPassword(_email.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('If an account exists, a reset link has been sent.')),
      );
      context.go('/auth/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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
            // Logo
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
            Text('Forgot Password',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF0A7B70))),
            const SizedBox(height: 6),
            Text(
              'Enter the email associated with your account and\nwe’ll send a link to reset your password.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], height: 1.35),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Email field (same style as login)
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter email';
                final ok = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);
                return ok ? null : 'Invalid email';
              },
              decoration: InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: const Color(0xFFEAF6F4),
                prefixIcon: const Icon(Icons.mail_outlined, color: Color(0xFF0A7B70)),
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
            ),

            const SizedBox(height: 20),

            // Button
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
                    : Text('Send Reset Link',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
              ),
            ),

            const SizedBox(height: 16),

            // Back to login
            GestureDetector(
              onTap: () => context.go('/auth/login'),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 14),
                  children: const [
                    TextSpan(text: 'Remembered your password? '),
                    TextSpan(text: 'Back to Login', style: TextStyle(color: Color(0xFF0A7B70), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
