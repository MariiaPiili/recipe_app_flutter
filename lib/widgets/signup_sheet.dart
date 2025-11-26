import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupSheet extends StatefulWidget {
  final VoidCallback onSignedUp;

  const SignupSheet({super.key, required this.onSignedUp});

  @override
  State<SignupSheet> createState() => _SignupSheetState();
}

class _SignupSheetState extends State<SignupSheet> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool obscure = true;

  // новый state
  bool _isLoginMode = false; // false = Sign Up, true = Log In
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final auth = AuthService();

      if (_isLoginMode) {
        // ---- LOG IN ----
        await auth.signInWithEmail(email: email, password: password);
      } else {
        // ---- SIGN UP ----
        await auth.signUpWithEmail(email: email, password: password);
      }

      if (!context.mounted) return;

      // успех — ведём дальше (на Home, как и раньше)
      widget.onSignedUp();
    } catch (e) {
      if (!context.mounted) return;
      setState(() {
        _errorText = 'Authentication error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = MediaQuery.of(context).size.height;

    final title = _isLoginMode ? 'Sign In' : 'Sign Up';
    final primaryButtonText = _isLoginMode ? 'Log in' : 'Create account';
    final switchText = _isLoginMode
        ? "Don't have an account? Sign up"
        : 'Already have an account? Sign in';

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        top: h * 0.18,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(blurRadius: 30, color: Colors.black.withOpacity(0.15)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // “ручка”
              Container(
                height: 5,
                width: 46,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _Field(
                controller: emailCtrl,
                hint: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: passCtrl,
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                obscure: obscure,
                suffix: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (_errorText != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_errorText!, style: TextStyle(color: cs.error)),
                ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          primaryButtonText,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                          _errorText = null;
                        });
                      },
                child: Text(switchText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: cs.surfaceVariant.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
