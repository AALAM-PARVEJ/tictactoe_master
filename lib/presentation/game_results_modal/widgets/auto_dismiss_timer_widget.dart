import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AutoDismissTimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onTimerComplete;

  const AutoDismissTimerWidget({
    Key? key,
    required this.initialSeconds,
    required this.onTimerComplete,
  }) : super(key: key);

  @override
  State<AutoDismissTimerWidget> createState() => _AutoDismissTimerWidgetState();
}

class _AutoDismissTimerWidgetState extends State<AutoDismissTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;

    _timerController = AnimationController(
      duration: Duration(seconds: widget.initialSeconds),
      vsync: this,
    );

    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: Curves.linear,
    ));

    _timerController.addListener(() {
      final newSeconds = (_timerAnimation.value * widget.initialSeconds).ceil();
      if (newSeconds != _remainingSeconds) {
        setState(() {
          _remainingSeconds = newSeconds;
        });
      }
    });

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimerComplete();
      }
    });

    _timerController.forward();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 4.w,
            height: 4.w,
            child: AnimatedBuilder(
              animation: _timerAnimation,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: 1.0 - _timerAnimation.value,
                  strokeWidth: 2,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'Auto-close in ${_remainingSeconds}s',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
