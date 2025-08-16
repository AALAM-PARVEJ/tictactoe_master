import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class GameGridWidget extends StatelessWidget {
  final List<List<String>> gameBoard;
  final Function(int, int) onCellTap;
  final List<List<int>>? winningCombination;
  final bool isGameActive;

  const GameGridWidget({
    Key? key,
    required this.gameBoard,
    required this.onCellTap,
    this.winningCombination,
    required this.isGameActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 85.w,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final row = index ~/ 3;
            final col = index % 3;
            final cellValue = gameBoard[row][col];
            final isWinningCell = _isWinningCell(row, col);

            return GestureDetector(
              onTap: isGameActive && cellValue.isEmpty
                  ? () {
                      HapticFeedback.lightImpact();
                      onCellTap(row, col);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isWinningCell
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWinningCell
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: isWinningCell ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: cellValue.isNotEmpty
                        ? Text(
                            cellValue,
                            key: ValueKey(cellValue),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: cellValue == 'X'
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.secondary,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isWinningCell(int row, int col) {
    if (winningCombination == null) return false;
    return winningCombination!
        .any((combination) => combination[0] == row && combination[1] == col);
  }
}
