import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickSetupPresets extends StatelessWidget {
  final Function(String, String, String, String) onPresetSelected;

  const QuickSetupPresets({
    Key? key,
    required this.onPresetSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'flash_on',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Quick Setup',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Preset Buttons
          Row(
            children: [
              Expanded(
                child: _buildPresetButton(
                  context,
                  'Classic',
                  'Player 1 (X) vs Player 2 (O)',
                  () => onPresetSelected('Player 1', 'X', 'Player 2', 'O'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildPresetButton(
                  context,
                  'Reversed',
                  'Player 1 (O) vs Player 2 (X)',
                  () => onPresetSelected('Player 1', 'O', 'Player 2', 'X'),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SizedBox(
            width: double.infinity,
            child: _buildPresetButton(
              context,
              'Random',
              'Random symbols assignment',
              () {
                final bool player1GetsX =
                    DateTime.now().millisecondsSinceEpoch % 2 == 0;
                onPresetSelected(
                  'Player 1',
                  player1GetsX ? 'X' : 'O',
                  'Player 2',
                  player1GetsX ? 'O' : 'X',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          color:
              AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
