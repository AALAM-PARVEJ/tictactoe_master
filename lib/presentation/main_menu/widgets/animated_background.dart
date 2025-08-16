import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _rotationController;
  late List<FloatingSymbol> _symbols;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _generateSymbols();
  }

  void _generateSymbols() {
    _symbols = List.generate(8, (index) {
      return FloatingSymbol(
        symbol: index % 2 == 0 ? 'X' : 'O',
        startX: math.Random().nextDouble() * 100.w,
        startY: math.Random().nextDouble() * 100.h,
        speed: 0.3 + math.Random().nextDouble() * 0.7,
        size: 3.h + math.Random().nextDouble() * 2.h,
        opacity: 0.1 + math.Random().nextDouble() * 0.2,
      );
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.surface,
            AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
            AppTheme.lightTheme.colorScheme.primaryContainer
                .withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Grid pattern
          CustomPaint(
            size: Size(100.w, 100.h),
            painter: GridPatternPainter(),
          ),
          // Floating symbols
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Stack(
                children: _symbols.map((symbol) {
                  final progress = _floatingController.value;
                  final yOffset =
                      (progress * symbol.speed * 100.h) % (100.h + symbol.size);

                  return Positioned(
                    left: symbol.startX,
                    top: symbol.startY + yOffset - symbol.size,
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: Opacity(
                            opacity: symbol.opacity,
                            child: Text(
                              symbol.symbol,
                              style: TextStyle(
                                fontSize: symbol.size,
                                fontWeight: FontWeight.bold,
                                color: symbol.symbol == 'X'
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FloatingSymbol {
  final String symbol;
  final double startX;
  final double startY;
  final double speed;
  final double size;
  final double opacity;

  FloatingSymbol({
    required this.symbol,
    required this.startX,
    required this.startY,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 60.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
