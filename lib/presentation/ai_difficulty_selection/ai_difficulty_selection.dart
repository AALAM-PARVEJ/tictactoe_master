import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/difficulty_card_widget.dart';
import './widgets/difficulty_tooltip_widget.dart';
import './widgets/quick_play_toggle_widget.dart';

class AiDifficultySelection extends StatefulWidget {
  const AiDifficultySelection({Key? key}) : super(key: key);

  @override
  State<AiDifficultySelection> createState() => _AiDifficultySelectionState();
}

class _AiDifficultySelectionState extends State<AiDifficultySelection>
    with SingleTickerProviderStateMixin {
  String? selectedDifficulty;
  bool quickPlayEnabled = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> difficultyLevels = [
    {
      "id": "easy",
      "title": "Easy",
      "description":
          "Perfect for beginners. AI makes random moves with occasional strategic plays.",
      "icon": "sentiment_satisfied",
      "color": const Color(0xFF059669),
      "strategy":
          "AI makes random moves with 30% chance of blocking player wins",
      "winRate": "85%",
    },
    {
      "id": "medium",
      "title": "Medium",
      "description":
          "Balanced challenge. AI uses basic strategy and defensive moves.",
      "icon": "psychology",
      "color": const Color(0xFFD97706),
      "strategy":
          "AI uses basic strategy, blocks wins and creates opportunities",
      "winRate": "60%",
    },
    {
      "id": "hard",
      "title": "Hard",
      "description":
          "Expert level. AI employs minimax algorithm for optimal play.",
      "icon": "military_tech",
      "color": const Color(0xFFDC2626),
      "strategy": "AI uses minimax algorithm for perfect strategic gameplay",
      "winRate": "25%",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPreferences();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        selectedDifficulty = prefs.getString('last_difficulty');
        quickPlayEnabled = prefs.getBool('quick_play_enabled') ?? false;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (selectedDifficulty != null) {
        await prefs.setString('last_difficulty', selectedDifficulty!);
      }
      await prefs.setBool('quick_play_enabled', quickPlayEnabled);
    } catch (e) {
      // Handle error silently
    }
  }

  void _selectDifficulty(String difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
    });
    HapticFeedback.selectionClick();
  }

  void _toggleQuickPlay(bool value) {
    setState(() {
      quickPlayEnabled = value;
    });
    _savePreferences();
  }

  void _startGame() {
    if (selectedDifficulty != null) {
      _savePreferences();
      HapticFeedback.mediumImpact();
      Navigator.pushNamed(
        context,
        '/game-board',
        arguments: {
          'gameMode': 'ai',
          'difficulty': selectedDifficulty,
          'quickPlay': quickPlayEnabled,
        },
      );
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: _goBack,
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        title: Text(
          'Choose Difficulty',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: DifficultyTooltipWidget(
              difficulty: selectedDifficulty ?? 'none',
              strategy: selectedDifficulty != null
                  ? (difficultyLevels.firstWhere(
                      (level) => (level["id"] as String) == selectedDifficulty,
                      orElse: () => {"strategy": "No strategy available"},
                    )["strategy"] as String)
                  : 'Select a difficulty to see AI strategy',
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'Select AI Opponent Strength',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'Choose the perfect challenge level for your Tic Tac Toe experience',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      ...difficultyLevels.map((level) {
                        final isSelected =
                            selectedDifficulty == (level["id"] as String);
                        return DifficultyCardWidget(
                          title: level["title"] as String,
                          description: level["description"] as String,
                          iconName: level["icon"] as String,
                          themeColor: level["color"] as Color,
                          isSelected: isSelected,
                          winRate: level["winRate"] as String?,
                          onTap: () => _selectDifficulty(level["id"] as String),
                        );
                      }).toList(),
                      SizedBox(height: 2.h),
                      QuickPlayToggleWidget(
                        isEnabled: quickPlayEnabled,
                        onChanged: _toggleQuickPlay,
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (selectedDifficulty != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            vertical: 2.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'info',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 5.w,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                'Selected: ${difficultyLevels.firstWhere((level) => (level["id"] as String) == selectedDifficulty)["title"]} - ${difficultyLevels.firstWhere((level) => (level["id"] as String) == selectedDifficulty)["winRate"]} player win rate',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed:
                            selectedDifficulty != null ? _startGame : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedDifficulty != null
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                          foregroundColor: Colors.white,
                          elevation: selectedDifficulty != null ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'play_arrow',
                              color: Colors.white,
                              size: 6.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Start Game',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
