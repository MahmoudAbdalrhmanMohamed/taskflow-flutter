import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PriorityChip extends StatelessWidget {
  final String priority;
  final bool isSmall;

  const PriorityChip({
    super.key,
    required this.priority,
    this.isSmall = false,
  });

  Color _getPriorityColor() {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return AppColors.priorityHigh;
      case 'MEDIUM':
        return AppColors.priorityMedium;
      case 'LOW':
      default:
        return AppColors.priorityLow;
    }
  }

  IconData _getPriorityIcon() {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'MEDIUM':
        return Icons.keyboard_arrow_up_rounded;
      case 'LOW':
      default:
        return Icons.keyboard_arrow_down_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor();
    final icon = _getPriorityIcon();
    final label = priority.toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 13 : 15, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
