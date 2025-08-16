import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _xAnimationController;
  late AnimationController _oAnimationController;
  late AnimationController _loadingAnimationController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _xScaleAnimation;
  late Animation<double> _xFadeAnimation;
  late Animation<double> _oScaleAnimation;
  late Animation<double> _oFadeAnimation;
  late Animation<double> _loadingAnimation;

  bool _isInitialized = false;
  double _initializationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // X symbol animation controller
    _xAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // O symbol animation controller
    _oAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // X symbol animations
    _xScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _xAnimationController,
      curve: Curves.bounceOut,
    ));

    _xFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _xAnimationController,
      curve: Curves.easeIn,
    ));

    // O symbol animations
    _oScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _oAnimationController,
      curve: Curves.bounceOut,
    ));

    _oFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _oAnimationController,
      curve: Curves.easeIn,
    ));

    // Loading animation
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start logo animation
    _logoAnimationController.forward();

    // Wait for logo to appear, then start X and O animations
    await Future.delayed(const Duration(milliseconds: 800));
    _xAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _oAnimationController.forward();

    // Start loading animation
    await Future.delayed(const Duration(milliseconds: 500));
    _loadingAnimationController.repeat();
  }

  Future<void> _startInitialization() async {
    try {
      // Simulate loading game preferences
      await _updateProgress(0.2, "Loading preferences...");
      await Future.delayed(const Duration(milliseconds: 400));

      // Simulate initializing AI algorithms
      await _updateProgress(0.4, "Initializing AI...");
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate checking saved game states
      await _updateProgress(0.6, "Checking saved games...");
      await Future.delayed(const Duration(milliseconds: 300));

      // Simulate preparing sound/haptic systems
      await _updateProgress(0.8, "Preparing systems...");
      await Future.delayed(const Duration(milliseconds: 400));

      // Complete initialization
      await _updateProgress(1.0, "Ready to play!");
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _isInitialized = true;
      });

      // Navigate to main menu after initialization
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToMainMenu();
    } catch (e) {
      // Handle initialization errors gracefully
      await Future.delayed(const Duration(milliseconds: 2000));
      _navigateToMainMenu();
    }
  }

  Future<void> _updateProgress(double progress, String message) async {
    setState(() {
      _initializationProgress = progress;
    });
  }

  void _navigateToMainMenu() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main-menu');
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _xAnimationController.dispose();
    _oAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.8),
                  AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section with animated X and O
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main logo container
                        AnimatedBuilder(
                          animation: _logoAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoScaleAnimation.value,
                              child: Opacity(
                                opacity: _logoFadeAnimation.value,
                                child: Container(
                                  width: 45.w,
                                  height: 45.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4.w),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Grid lines
                                      CustomPaint(
                                        size: Size(45.w, 45.w),
                                        painter: _GridPainter(),
                                      ),
                                      // Animated X symbol
                                      Positioned(
                                        top: 2.w,
                                        left: 2.w,
                                        child: AnimatedBuilder(
                                          animation: _xAnimationController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _xScaleAnimation.value,
                                              child: Opacity(
                                                opacity: _xFadeAnimation.value,
                                                child: Container(
                                                  width: 11.w,
                                                  height: 11.w,
                                                  child: CustomPaint(
                                                    painter: _XPainter(),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      // Animated O symbol
                                      Positioned(
                                        bottom: 2.w,
                                        right: 2.w,
                                        child: AnimatedBuilder(
                                          animation: _oAnimationController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _oScaleAnimation.value,
                                              child: Opacity(
                                                opacity: _oFadeAnimation.value,
                                                child: Container(
                                                  width: 11.w,
                                                  height: 11.w,
                                                  child: CustomPaint(
                                                    painter: _OPainter(),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 4.h),
                        // App title
                        AnimatedBuilder(
                          animation: _logoAnimationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoFadeAnimation.value,
                              child: Column(
                                children: [
                                  Text(
                                    'TicTacToe',
                                    style: AppTheme
                                        .lightTheme.textTheme.displayMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'MASTER',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleLarge
                                        ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Loading section
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading indicator
                      AnimatedBuilder(
                        animation: _loadingAnimationController,
                        builder: (context, child) {
                          return Container(
                            width: 60.w,
                            height: 0.8.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(1.h),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 60.w * _initializationProgress,
                                  height: 0.8.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(1.h),
                                  ),
                                ),
                                if (!_isInitialized)
                                  Positioned(
                                    left: (60.w * _loadingAnimation.value) %
                                        (60.w - 8.w),
                                    child: Container(
                                      width: 8.w,
                                      height: 0.8.h,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.6),
                                        borderRadius:
                                            BorderRadius.circular(1.h),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 2.h),
                      // Loading text
                      Text(
                        _isInitialized ? 'Ready to Play!' : 'Loading...',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Version info
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Text(
                    'Version 1.0.0',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for grid lines
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double cellSize = size.width / 3;

    // Vertical lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(cellSize * i, 0),
        Offset(cellSize * i, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, cellSize * i),
        Offset(size.width, cellSize * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for X symbol
class _XPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double padding = size.width * 0.2;

    // Draw X
    canvas.drawLine(
      Offset(padding, padding),
      Offset(size.width - padding, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(padding, size.height - padding),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for O symbol
class _OPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final double radius = size.width * 0.3;
    final Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
