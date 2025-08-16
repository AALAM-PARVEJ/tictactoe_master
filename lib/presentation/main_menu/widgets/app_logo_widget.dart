import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AppLogoWidget extends StatefulWidget {
  const AppLogoWidget({Key? key}) : super(key: key);

  @override
  State<AppLogoWidget> createState() => _AppLogoWidgetState();
}

class _AppLogoWidgetState extends State<AppLogoWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Column(
            children: [
              Container(
                width: 20.h,
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: CustomPaint(
                      size: Size(15.h, 15.h),
                      painter: TicTacToeLogoPainter(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'TicTacToe Master',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Challenge Your Mind',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class TicTacToeLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridSize = size.width / 3;

    // Draw grid lines
    paint.color = AppTheme.lightTheme.colorScheme.primary;

    // Vertical lines
    canvas.drawLine(
      Offset(gridSize, 0),
      Offset(gridSize, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(gridSize * 2, 0),
      Offset(gridSize * 2, size.height),
      paint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(0, gridSize),
      Offset(size.width, gridSize),
      paint,
    );
    canvas.drawLine(
      Offset(0, gridSize * 2),
      Offset(size.width, gridSize * 2),
      paint,
    );

    // Draw X in top-left
    paint.color = AppTheme.lightTheme.colorScheme.primary;
    paint.strokeWidth = 6;
    final xPadding = gridSize * 0.2;
    canvas.drawLine(
      Offset(xPadding, xPadding),
      Offset(gridSize - xPadding, gridSize - xPadding),
      paint,
    );
    canvas.drawLine(
      Offset(gridSize - xPadding, xPadding),
      Offset(xPadding, gridSize - xPadding),
      paint,
    );

    // Draw O in center
    paint.color = AppTheme.lightTheme.colorScheme.secondary;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    final oCenter = Offset(gridSize * 1.5, gridSize * 1.5);
    final oRadius = gridSize * 0.3;
    canvas.drawCircle(oCenter, oRadius, paint);

    // Draw X in bottom-right
    paint.color = AppTheme.lightTheme.colorScheme.primary;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    final x2Padding = gridSize * 0.2;
    canvas.drawLine(
      Offset(gridSize * 2 + x2Padding, gridSize * 2 + x2Padding),
      Offset(gridSize * 3 - x2Padding, gridSize * 3 - x2Padding),
      paint,
    );
    canvas.drawLine(
      Offset(gridSize * 3 - x2Padding, gridSize * 2 + x2Padding),
      Offset(gridSize * 2 + x2Padding, gridSize * 3 - x2Padding),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
