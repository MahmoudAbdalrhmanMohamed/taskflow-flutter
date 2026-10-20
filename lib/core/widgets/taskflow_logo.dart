import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TaskFlowLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isVertical;
  final String? subtitle;

  const TaskFlowLogo({
    super.key,
    this.size = 48,
    this.showText = false,
    this.isVertical = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logoBadge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Indigo
            Color(0xFF8B5CF6), // Violet
            Color(0xFF06B6D4), // Cyan
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.35),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.2),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle layered geometric accent
          Positioned(
            right: size * 0.1,
            bottom: size * 0.1,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Core velocity checkmark + flow icon
          Icon(
            Icons.done_all_rounded,
            color: Colors.white,
            size: size * 0.58,
          ),
        ],
      ),
    );

    if (!showText) {
      return logoBadge;
    }

    final textColumn = Column(
      crossAxisAlignment:
          isVertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Task',
                style: TextStyle(
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Flow',
                style: TextStyle(
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            textAlign: isVertical ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: (size * 0.22).clamp(11.0, 14.0),
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoBadge,
          SizedBox(height: size * 0.25),
          textColumn,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoBadge,
        SizedBox(width: size * 0.25),
        textColumn,
      ],
    );
  }
}
