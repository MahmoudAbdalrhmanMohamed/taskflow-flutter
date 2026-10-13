import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusChip({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'DONE':
        return AppColors.statusDone;
      case 'IN_PROGRESS':
        return AppColors.statusInProgress;
      case 'TODO':
      default:
        return AppColors.statusTodo;
    }
  }

  String _getDisplayLabel() {
    switch (status.toUpperCase()) {
      case 'DONE':
        return 'Done';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'TODO':
      default:
        return 'To Do';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final label = _getDisplayLabel();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 6 : 8,
            height: isSmall ? 6 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
