import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CelebrationAnimationWidget extends StatefulWidget {
  final String gameResult;

  const CelebrationAnimationWidget({
    Key? key,
    required this.gameResult,
  }) : super(key: key);

  @override
  State<CelebrationAnimationWidget> createState() =>
      _CelebrationAnimationWidgetState();
}

class _CelebrationAnimationWidgetState extends State<CelebrationAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _confettiAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOutQuart,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));

    if (widget.gameResult == 'win') {
      _confettiController.forward();
    } else if (widget.gameResult == 'draw') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gameResult == 'win') {
      return AnimatedBuilder(
        animation: _confettiAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              ...List.generate(20, (index) {
                final double randomX = (index % 5) * 20.w;
                final double randomDelay = (index % 3) * 0.2;
                return Positioned(
                  left: randomX,
                  top: -10.h + (_confettiAnimation.value * 60.h),
                  child: Transform.rotate(
                    angle: _confettiAnimation.value *
                        6.28 *
                        (index % 2 == 0 ? 1 : -1),
                    child: Opacity(
                      opacity: 1.0 - _confettiAnimation.value,
                      child: Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color: index % 4 == 0
                              ? AppTheme.lightTheme.colorScheme.primary
                              : index % 4 == 1
                                  ? AppTheme.lightTheme.colorScheme.secondary
                                  : index % 4 == 2
                                      ? AppTheme.getSuccessColor(true)
                                      : AppTheme.getWarningColor(true),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      );
    } else if (widget.gameResult == 'draw') {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.getWarningColor(true).withValues(alpha: 0.2),
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
