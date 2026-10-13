import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../data/models/task_model.dart';

class TaskFormDialog extends ConsumerStatefulWidget {
  final TaskModel? task;
  final String? defaultProjectId;
  final String? defaultStatus;
  final Function({
    required String title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    required String projectId,
  }) onSave;

  const TaskFormDialog({
    super.key,
    this.task,
    this.defaultProjectId,
    this.defaultStatus,
    required this.onSave,
  });

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  String? _selectedProjectId;
  late String _selectedStatus;
  late String _selectedPriority;
  DateTime? _selectedDueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _selectedProjectId = widget.task?.projectId ?? widget.defaultProjectId;
    _selectedStatus = widget.task?.status ?? widget.defaultStatus ?? 'TODO';
    _selectedPriority = widget.task?.priority ?? 'MEDIUM';
    _selectedDueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project')),
      );
      return;
    }

    setState(() => _isSaving = true);

    await widget.onSave(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      dueDate: _selectedDueDate,
      projectId: _selectedProjectId!,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final projects = projectsState.projects;
    final isEditing = widget.task != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Set fallback project if not selected
    if (_selectedProjectId == null && projects.isNotEmpty) {
      _selectedProjectId = projects.first.id;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                        isEditing ? 'Edit Task' : 'Create New Task',
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
                    controller: _titleController,
                    label: 'Task Title',
                    hint: 'e.g. Implement biometrics flow',
                    prefixIcon: Icons.task_alt_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: _descController,
                    label: 'Description (Optional)',
                    hint: 'Details, requirements, and acceptance criteria',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),

                  // Project Dropdown
                  const Text(
                    'Assign to Project',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedProjectId,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.folder_outlined, size: 20),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: projects.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedProjectId = val),
                    validator: (v) => v == null ? 'Project is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Status and Priority Row
                  Row(
                    children: [
                      // Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedStatus,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'TODO', child: Text('To Do')),
                                DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                                DropdownMenuItem(value: 'DONE', child: Text('Done')),
                              ],
                              onChanged: (v) => setState(() => _selectedStatus = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Priority
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Priority',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedPriority,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'LOW', child: Text('Low')),
                                DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                                DropdownMenuItem(value: 'HIGH', child: Text('High')),
                              ],
                              onChanged: (v) => setState(() => _selectedPriority = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Due Date
                  const Text(
                    'Due Date',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickDueDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDueDate != null
                                ? DateFormat('MMMM d, yyyy').format(_selectedDueDate!)
                                : 'Select due date (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedDueDate != null
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                          const Spacer(),
                          if (_selectedDueDate != null)
                            GestureDetector(
                              onTap: () => setState(() => _selectedDueDate = null),
                              child: const Icon(Icons.clear_rounded, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: isEditing ? 'Save Changes' : 'Create Task',
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
