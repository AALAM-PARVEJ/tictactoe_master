import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DifficultyTooltipWidget extends StatelessWidget {
  final String difficulty;
  final String strategy;

  const DifficultyTooltipWidget({
    Key? key,
    required this.difficulty,
    required this.strategy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: strategy,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
        color: AppTheme.lightTheme.colorScheme.surface,
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      child: Container(
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomIconWidget(
          iconName: 'info_outline',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 4.w,
        ),
      ),
    );
  }
}
