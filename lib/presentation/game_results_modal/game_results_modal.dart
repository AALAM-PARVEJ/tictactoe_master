import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/auto_dismiss_timer_widget.dart';
import './widgets/celebration_animation_widget.dart';
import './widgets/game_statistics_widget.dart';
import './widgets/result_header_widget.dart';

class GameResultsModal extends StatefulWidget {
  const GameResultsModal({Key? key}) : super(key: key);

  @override
  State<GameResultsModal> createState() => _GameResultsModalState();
}

class _GameResultsModalState extends State<GameResultsModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Mock game data
  final Map<String, dynamic> gameData = {
    "result": "win", // win, lose, draw
    "gameMode": "ai", // ai, human
    "difficulty": "Medium",
    "moveCount": 7,
    "gameDuration": "2:34",
    "playerStats": {
      "wins": 12,
      "losses": 8,
      "draws": 3,
      "currentStreak": 4,
    },
    "winningCombination": [0, 1, 2], // For highlighting winning positions
  };

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start slide animation
    _slideController.forward();

    // Provide haptic feedback based on result
    _provideResultFeedback();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _provideResultFeedback() {
    switch (gameData["result"]) {
      case "win":
        HapticFeedback.heavyImpact();
        break;
      case "lose":
        HapticFeedback.mediumImpact();
        break;
      case "draw":
        HapticFeedback.lightImpact();
        break;
    }
  }

  String _getResultText() {
    switch (gameData["result"]) {
      case "win":
        return "You Win!";
      case "lose":
        return "You Lose!";
      case "draw":
        return "It's a Draw!";
      default:
        return "Game Over";
    }
  }

  String _getResultEmoji() {
    switch (gameData["result"]) {
      case "win":
        return "🎉";
      case "lose":
        return "😔";
      case "draw":
        return "🤝";
      default:
        return "🎮";
    }
  }

  Color _getResultColor() {
    switch (gameData["result"]) {
      case "win":
        return AppTheme.getSuccessColor(true);
      case "lose":
        return AppTheme.lightTheme.colorScheme.error;
      case "draw":
        return AppTheme.getWarningColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _handlePlayAgain() {
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, '/game-board');
  }

  void _handleChangeDifficulty() {
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, '/ai-difficulty-selection');
  }

  void _handleMainMenu() {
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, '/main-menu');
  }

  void _handleShare() {
    final String shareText =
        "I just ${gameData["result"] == "win" ? "won" : gameData["result"] == "draw" ? "drew" : "played"} a game of Tic Tac Toe! "
        "Moves: ${gameData["moveCount"]}, Duration: ${gameData["gameDuration"]}. "
        "My record: ${gameData["playerStats"]["wins"]}W-${gameData["playerStats"]["losses"]}L-${gameData["playerStats"]["draws"]}D";

    // Copy to clipboard as a simple share mechanism
    Clipboard.setData(ClipboardData(text: shareText));
    Fluttertoast.showToast(
      msg: "Game result copied to clipboard!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleAutoDismiss() {
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, '/main-menu');
  }

  void _dismissModal() {
    _slideController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _dismissModal();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        body: GestureDetector(
          onTap: _dismissModal,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Celebration animation overlay
                if (gameData["result"] == "win" || gameData["result"] == "draw")
                  Positioned.fill(
                    child: CelebrationAnimationWidget(
                      gameResult: gameData["result"],
                    ),
                  ),

                // Main modal content
                Center(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: GestureDetector(
                      onTap: () {}, // Prevent tap through
                      child: Container(
                        width: 90.w,
                        constraints: BoxConstraints(
                          maxHeight: 85.h,
                          maxWidth: 400,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Close button
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.all(2.w),
                                child: GestureDetector(
                                  onTap: _dismissModal,
                                  child: Container(
                                    padding: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.surface,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'close',
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Result header
                            ResultHeaderWidget(
                              result: _getResultText(),
                              emoji: _getResultEmoji(),
                              resultColor: _getResultColor(),
                            ),

                            // Game statistics
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: GameStatisticsWidget(
                                moveCount: gameData["moveCount"],
                                gameDuration: gameData["gameDuration"],
                                wins: gameData["playerStats"]["wins"],
                                losses: gameData["playerStats"]["losses"],
                                draws: gameData["playerStats"]["draws"],
                                currentStreak: gameData["playerStats"]
                                    ["currentStreak"],
                                difficulty: gameData["difficulty"],
                              ),
                            ),

                            SizedBox(height: 3.h),

                            // Action buttons
                            ActionButtonsWidget(
                              gameMode: gameData["gameMode"],
                              onPlayAgain: _handlePlayAgain,
                              onChangeDifficulty: _handleChangeDifficulty,
                              onMainMenu: _handleMainMenu,
                              onShare: _handleShare,
                            ),

                            // Auto-dismiss timer
                            AutoDismissTimerWidget(
                              initialSeconds: 10,
                              onTimerComplete: _handleAutoDismiss,
                            ),

                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
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
