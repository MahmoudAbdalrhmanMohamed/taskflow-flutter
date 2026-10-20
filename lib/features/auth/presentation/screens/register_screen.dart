import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/taskflow_logo.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          jobTitle: _jobTitleController.text.trim(),
          department: _departmentController.text.trim(),
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
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: TaskFlowLogo(
                            size: 60,
                            showText: false,
                          ),
                        ),
                        const SizedBox(height: 20),
                Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join your team workspace on TaskFlow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (authState.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.priorityHigh.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.priorityHigh,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Alex Morgan',
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _emailController,
                          label: 'Work Email',
                          hint: 'alex@company.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Min. 6 characters',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => v == null || v.length < 6 ? 'Min. 6 characters required' : null,
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _jobTitleController,
                                label: 'Job Title (Optional)',
                                hint: 'e.g. Lead Engineer',
                                prefixIcon: Icons.work_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _departmentController,
                                label: 'Department',
                                hint: 'e.g. Product',
                                prefixIcon: Icons.business_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Create Account',
                          isLoading: authState.isLoading,
                          onPressed: _handleRegister,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'Sign in',
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
