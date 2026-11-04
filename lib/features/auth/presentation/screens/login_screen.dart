import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/core/constants/app_strings.dart';
import 'package:noticewise/features/auth/domain/auth_failure.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';
import 'package:noticewise/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:noticewise/features/auth/presentation/widgets/demo_accounts_card.dart';
import 'package:noticewise/features/auth/presentation/widgets/demo_mode_banner.dart';

/// Login screen with email/password form, demo accounts card, and
/// navigation to sign-up and forgot-password screens.
///
/// ⚠️  Demo mode: authentication is local only. See [DemoModeBanner].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _quickLogin(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    // Show error snackbar when auth fails
    ref.listen(authControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          final msg = e is AuthFailure ? e.message : AppStrings.errorGeneric;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const DemoModeBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      // ── App logo / title ────────────────────────────────
                      Icon(
                        Icons.campaign_rounded,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.appName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.appTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // ── Email ────────────────────────────────────────────
                      AuthFormField(
                        controller: _emailController,
                        label: AppStrings.authEmailLabel,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        enabled: !isLoading,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required.';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                              .hasMatch(v.trim())) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Password ─────────────────────────────────────────
                      AuthFormField(
                        controller: _passwordController,
                        label: AppStrings.authPasswordLabel,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required.';
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                      ),

                      // ── Forgot password ───────────────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.push(AppRoutes.forgotPassword),
                          child: const Text(AppStrings.authForgotPassword),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Sign in button ────────────────────────────────────
                      FilledButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(AppStrings.authSignIn),
                      ),
                      const SizedBox(height: 24),

                      // ── Demo accounts ─────────────────────────────────────
                      DemoAccountsCard(onQuickLogin: _quickLogin),
                      const SizedBox(height: 24),

                      // ── Sign up link ──────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.push(AppRoutes.signup),
                            child: const Text(AppStrings.authSignUp),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
