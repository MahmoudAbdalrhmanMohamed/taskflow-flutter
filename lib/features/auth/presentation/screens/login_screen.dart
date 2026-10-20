import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/taskflow_logo.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@taskflow.dev');
  final _passwordController = TextEditingController(text: 'DemoPassword123!');
  final _scrollController = ScrollController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _autofillDemo() {
    setState(() {
      _emailController.text = 'demo@taskflow.dev';
      _passwordController.text = 'DemoPassword123!';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo credentials autofilled!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo & Header
                        const Center(
                          child: TaskFlowLogo(
                            size: 64,
                            showText: false,
                          ),
                        ),
                        const SizedBox(height: 24),
                Text(
                  'Welcome to TaskFlow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Smart Team & Project Management Workspace',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Card Container
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Demo Autofill Banner
                        InkWell(
                          onTap: _autofillDemo,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.flash_on_rounded, size: 18, color: AppColors.primary),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Quick Demo Autofill (1-Click)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Error Banner
                        if (authState.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.priorityHigh.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.priorityHigh.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        color: AppColors.priorityHigh, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        authState.errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.priorityHigh,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    ref.read(authProvider.notifier).loginDemoOffline();
                                    context.go('/dashboard');
                                  },
                                  icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                                  label: const Text(
                                    'Continue in Offline Demo Mode',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@company.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        CustomButton(
                          text: 'Sign In',
                          isLoading: authState.isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(authProvider.notifier).loginDemoOffline();
                            context.go('/dashboard');
                          },
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: const Text('Instant Demo Mode (Offline)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
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
          ),
        );
      },
    ),
  );
  }
}
