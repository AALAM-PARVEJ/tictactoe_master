import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class GameStatusWidget extends StatelessWidget {
  final String gameStatus;
  final String currentPlayer;
  final bool isGameActive;

  const GameStatusWidget({
    Key? key,
    required this.gameStatus,
    required this.currentPlayer,
    required this.isGameActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          _getStatusText(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: _getStatusColor(),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getStatusText() {
    if (!isGameActive) {
      if (gameStatus.contains('wins')) {
        return gameStatus;
      } else if (gameStatus.contains('Draw')) {
        return "It's a Draw! 🤝";
      }
    }
    return "Player $currentPlayer's Turn";
  }

  Color _getStatusColor() {
    if (!isGameActive) {
      if (gameStatus.contains('wins')) {
        return gameStatus.contains('X')
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.secondary;
      } else if (gameStatus.contains('Draw')) {
        return AppTheme.getWarningColor(true);
      }
    }
    return currentPlayer == 'X'
        ? AppTheme.lightTheme.colorScheme.primary
        : AppTheme.lightTheme.colorScheme.secondary;
  }
}
