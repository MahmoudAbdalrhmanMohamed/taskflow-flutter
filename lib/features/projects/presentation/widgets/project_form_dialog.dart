import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/project_model.dart';

class ProjectFormDialog extends StatefulWidget {
  final ProjectModel? project;
  final Function({
    required String name,
    String? description,
    String? color,
    String? icon,
    String? status,
  }) onSave;

  const ProjectFormDialog({
    super.key,
    this.project,
    required this.onSave,
  });

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late String _selectedColor;
  late String _selectedIcon;
  bool _isSaving = false;

  final List<String> _colorOptions = [
    '#6366F1', // Indigo
    '#8B5CF6', // Violet
    '#EC4899', // Pink
    '#3B82F6', // Blue
    '#10B981', // Emerald
    '#F59E0B', // Amber
    '#EF4444', // Rose
    '#06B6D4', // Cyan
  ];

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'folder', 'icon': Icons.folder_rounded},
    {'name': 'smartphone', 'icon': Icons.smartphone_rounded},
    {'name': 'server', 'icon': Icons.dns_rounded},
    {'name': 'shield', 'icon': Icons.shield_rounded},
    {'name': 'rocket', 'icon': Icons.rocket_launch_rounded},
    {'name': 'code', 'icon': Icons.code_rounded},
    {'name': 'palette', 'icon': Icons.palette_rounded},
    {'name': 'cloud', 'icon': Icons.cloud_queue_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descController = TextEditingController(text: widget.project?.description ?? '');
    _selectedColor = widget.project?.color ?? '#6366F1';
    _selectedIcon = widget.project?.icon ?? 'folder';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await widget.onSave(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Project' : 'Create New Project',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _nameController,
                    label: 'Project Name',
                    hint: 'e.g. Mobile App Redesign',
                    prefixIcon: Icons.folder_open_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Project name is required' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: _descController,
                    label: 'Description (Optional)',
                    hint: 'Brief goals, scope, and objectives',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Color Picker
                  const Text(
                    'Project Color',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _colorOptions.map((hex) {
                      final color = _parseHex(hex);
                      final isSelected = _selectedColor == hex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = hex),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Icon Picker
                  const Text(
                    'Project Icon',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _iconOptions.map((item) {
                      final isSelected = _selectedIcon == item['name'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = item['name']),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.15)
                                : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: isEditing ? 'Save Changes' : 'Create Project',
                    isLoading: _isSaving,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
