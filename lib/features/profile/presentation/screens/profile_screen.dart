import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';

// Theme mode provider for instant light/dark toggling
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final currentUrl = ref.read(apiClientProvider).baseUrl;
    _urlController = TextEditingController(text: currentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final user = ref.read(authProvider).user;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final titleCtrl = TextEditingController(text: user?.jobTitle ?? '');
    final deptCtrl = TextEditingController(text: user?.department ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameCtrl,
              label: 'Full Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: titleCtrl,
              label: 'Job Title',
              prefixIcon: Icons.work_outline,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: deptCtrl,
              label: 'Department',
              prefixIcon: Icons.business_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final apiClient = ref.read(apiClientProvider);
                await apiClient.patch('/users/profile', data: {
                  'name': nameCtrl.text.trim(),
                  'jobTitle': titleCtrl.text.trim(),
                  'department': deptCtrl.text.trim(),
                });
                ref.read(authProvider.notifier).checkAuthStatus();
                if (ctx.mounted) Navigator.of(ctx).pop();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changeBackendUrl(String newUrl) {
    ref.read(apiClientProvider).updateBaseUrl(newUrl);
    setState(() => _urlController.text = newUrl);
    // Refresh all data
    ref.read(dashboardProvider.notifier).fetchStats();
    ref.read(projectsProvider.notifier).fetchProjects();
    ref.read(tasksProvider.notifier).fetchTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched API Endpoint to: $newUrl'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.initials ?? 'U',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Alex Morgan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'demo@taskflow.dev',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user?.jobTitle != null || user?.department != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${user?.jobTitle ?? 'Architect'} • ${user?.department ?? 'Engineering'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profile Details'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Server Environment Configuration Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_sync_rounded, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text(
                        'API Server Environment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Switch between local dev backend and cloud deployed backend instantly:',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick Server Presets
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.computer_rounded, size: 16),
                        label: const Text('Localhost (3000)'),
                        onPressed: () =>
                            _changeBackendUrl('http://localhost:3000/api'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.phone_android_rounded, size: 16),
                        label: const Text('Android (10.0.2.2)'),
                        onPressed: () =>
                            _changeBackendUrl('http://10.0.2.2:3000/api'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.public_rounded, size: 16),
                        label: const Text('Vercel Cloud API'),
                        onPressed: () =>
                            _changeBackendUrl(AppConfig.productionBaseUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: _urlController,
                    label: 'Active Base URL',
                    prefixIcon: Icons.link_rounded,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_rounded, color: AppColors.statusDone),
                      onPressed: () => _changeBackendUrl(_urlController.text.trim()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Appearance & Preferences
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Theme Mode'),
                    subtitle: Text(themeMode == ThemeMode.dark
                        ? 'Dark Theme'
                        : (themeMode == ThemeMode.light
                            ? 'Light Theme'
                            : 'System Default')),
                    trailing: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                        ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
                        ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest)),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (val) {
                        ref.read(themeModeProvider.notifier).state = val.first;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            CustomButton(
              text: 'Sign Out',
              icon: Icons.logout_rounded,
              isOutlined: true,
              backgroundColor: AppColors.priorityHigh,
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
