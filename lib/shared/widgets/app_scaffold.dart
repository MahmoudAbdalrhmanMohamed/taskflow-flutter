import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/taskflow_logo.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/tasks')) return 2;
    if (location.startsWith('/kanban')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/tasks');
        break;
      case 3:
        context.go('/kanban');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        if (isWide) {
          // Tablet & Desktop: NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) => _onItemTapped(index, context),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: TaskFlowLogo(
                      size: 38,
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.folder_outlined),
                      selectedIcon: Icon(Icons.folder_rounded, color: AppColors.primary),
                      label: Text('Projects'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.checklist_rounded),
                      selectedIcon: Icon(Icons.checklist_rounded, color: AppColors.primary),
                      label: Text('Tasks'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.view_kanban_outlined),
                      selectedIcon: Icon(Icons.view_kanban_rounded, color: AppColors.primary),
                      label: Text('Kanban'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        // Mobile: BottomNavigationBar
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onItemTapped(index, context),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder_rounded, color: AppColors.primary),
                label: 'Projects',
              ),
              NavigationDestination(
                icon: Icon(Icons.checklist_rounded),
                selectedIcon: Icon(Icons.checklist_rounded, color: AppColors.primary),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_kanban_outlined),
                selectedIcon: Icon(Icons.view_kanban_rounded, color: AppColors.primary),
                label: 'Kanban',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
