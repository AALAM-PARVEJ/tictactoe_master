import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/ai_thinking_widget.dart';
import './widgets/game_action_buttons_widget.dart';
import './widgets/game_grid_widget.dart';
import './widgets/game_status_widget.dart';
import './widgets/player_indicator_widget.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  // Game state variables
  List<List<String>> gameBoard = List.generate(3, (_) => List.filled(3, ''));
  String currentPlayer = 'X';
  bool isGameActive = true;
  String gameStatus = '';
  List<List<int>>? winningCombination;
  bool isAiThinking = false;

  // Player information
  String player1Name = 'Player 1';
  String player2Name = 'AI';
  int player1Score = 0;
  int player2Score = 0;
  int drawCount = 0;

  // AI settings
  String aiDifficulty = 'Medium';
  bool isPlayingAgainstAi = true;

  // Animation controllers
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGameSettings();
  }

  void _initializeAnimations() {
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
  }

  void _loadGameSettings() {
    // In a real app, this would load from SharedPreferences
    // For now, using default values
    setState(() {
      player1Name = 'You';
      player2Name = isPlayingAgainstAi ? 'AI ($aiDifficulty)' : 'Player 2';
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _onCellTap(int row, int col) {
    if (!isGameActive || gameBoard[row][col].isNotEmpty || isAiThinking) {
      return;
    }

    setState(() {
      gameBoard[row][col] = currentPlayer;
    });

    if (_checkWinner()) {
      _handleGameEnd();
      return;
    }

    if (_isBoardFull()) {
      _handleDraw();
      return;
    }

    _switchPlayer();

    // AI move if playing against AI and it's AI's turn
    if (isPlayingAgainstAi && currentPlayer == 'O') {
      _makeAiMove();
    }
  }

  void _switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });
  }

  bool _checkWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (gameBoard[i][0].isNotEmpty &&
          gameBoard[i][0] == gameBoard[i][1] &&
          gameBoard[i][1] == gameBoard[i][2]) {
        winningCombination = [
          [i, 0],
          [i, 1],
          [i, 2]
        ];
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (gameBoard[0][i].isNotEmpty &&
          gameBoard[0][i] == gameBoard[1][i] &&
          gameBoard[1][i] == gameBoard[2][i]) {
        winningCombination = [
          [0, i],
          [1, i],
          [2, i]
        ];
        return true;
      }
    }

    // Check diagonals
    if (gameBoard[0][0].isNotEmpty &&
        gameBoard[0][0] == gameBoard[1][1] &&
        gameBoard[1][1] == gameBoard[2][2]) {
      winningCombination = [
        [0, 0],
        [1, 1],
        [2, 2]
      ];
      return true;
    }

    if (gameBoard[0][2].isNotEmpty &&
        gameBoard[0][2] == gameBoard[1][1] &&
        gameBoard[1][1] == gameBoard[2][0]) {
      winningCombination = [
        [0, 2],
        [1, 1],
        [2, 0]
      ];
      return true;
    }

    return false;
  }

  bool _isBoardFull() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (gameBoard[i][j].isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void _handleGameEnd() {
    setState(() {
      isGameActive = false;
      gameStatus = currentPlayer == 'X'
          ? '$player1Name wins! 🎉'
          : '$player2Name wins! 🎉';

      if (currentPlayer == 'X') {
        player1Score++;
      } else {
        player2Score++;
      }
    });

    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });

    HapticFeedback.heavyImpact();
    _showGameResultModal();
  }

  void _handleDraw() {
    setState(() {
      isGameActive = false;
      gameStatus = "It's a Draw! 🤝";
      drawCount++;
    });

    HapticFeedback.mediumImpact();
    _showGameResultModal();
  }

  void _makeAiMove() {
    setState(() {
      isAiThinking = true;
    });

    // Simulate AI thinking time
    Timer(Duration(milliseconds: Random().nextInt(1500) + 500), () {
      final move = _getAiMove();
      if (move != null) {
        setState(() {
          gameBoard[move[0]][move[1]] = 'O';
          isAiThinking = false;
        });

        if (_checkWinner()) {
          _handleGameEnd();
          return;
        }

        if (_isBoardFull()) {
          _handleDraw();
          return;
        }

        _switchPlayer();
      } else {
        setState(() {
          isAiThinking = false;
        });
      }
    });
  }

  List<int>? _getAiMove() {
    List<List<int>> availableMoves = [];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (gameBoard[i][j].isEmpty) {
          availableMoves.add([i, j]);
        }
      }
    }

    if (availableMoves.isEmpty) return null;

    switch (aiDifficulty) {
      case 'Easy':
        return _getRandomMove(availableMoves);
      case 'Medium':
        return _getMediumMove(availableMoves);
      case 'Hard':
        return _getHardMove(availableMoves);
      default:
        return _getRandomMove(availableMoves);
    }
  }

  List<int> _getRandomMove(List<List<int>> availableMoves) {
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  List<int> _getMediumMove(List<List<int>> availableMoves) {
    // Try to win first
    for (var move in availableMoves) {
      gameBoard[move[0]][move[1]] = 'O';
      if (_checkWinner()) {
        gameBoard[move[0]][move[1]] = '';
        winningCombination = null;
        return move;
      }
      gameBoard[move[0]][move[1]] = '';
    }

    // Try to block player from winning
    for (var move in availableMoves) {
      gameBoard[move[0]][move[1]] = 'X';
      if (_checkWinner()) {
        gameBoard[move[0]][move[1]] = '';
        winningCombination = null;
        return move;
      }
      gameBoard[move[0]][move[1]] = '';
    }

    // Take center if available
    if (gameBoard[1][1].isEmpty) {
      return [1, 1];
    }

    // Take corners
    List<List<int>> corners = [
      [0, 0],
      [0, 2],
      [2, 0],
      [2, 2]
    ];
    for (var corner in corners) {
      if (gameBoard[corner[0]][corner[1]].isEmpty) {
        return corner;
      }
    }

    return _getRandomMove(availableMoves);
  }

  List<int> _getHardMove(List<List<int>> availableMoves) {
    return _minimax(gameBoard, 0, true)['position'] ??
        _getRandomMove(availableMoves);
  }

  Map<String, dynamic> _minimax(
      List<List<String>> board, int depth, bool isMaximizing) {
    String result = _evaluateBoard(board);

    if (result == 'O') return {'score': 10 - depth};
    if (result == 'X') return {'score': depth - 10};
    if (result == 'draw') return {'score': 0};

    if (isMaximizing) {
      int bestScore = -1000;
      List<int>? bestMove;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j].isEmpty) {
            board[i][j] = 'O';
            int score = _minimax(board, depth + 1, false)['score'];
            board[i][j] = '';

            if (score > bestScore) {
              bestScore = score;
              bestMove = [i, j];
            }
          }
        }
      }

      return {'score': bestScore, 'position': bestMove};
    } else {
      int bestScore = 1000;
      List<int>? bestMove;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j].isEmpty) {
            board[i][j] = 'X';
            int score = _minimax(board, depth + 1, true)['score'];
            board[i][j] = '';

            if (score < bestScore) {
              bestScore = score;
              bestMove = [i, j];
            }
          }
        }
      }

      return {'score': bestScore, 'position': bestMove};
    }
  }

  String _evaluateBoard(List<List<String>> board) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0].isNotEmpty &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return board[i][0];
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i].isNotEmpty &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return board[0][i];
      }
    }

    // Check diagonals
    if (board[0][0].isNotEmpty &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return board[0][0];
    }

    if (board[0][2].isNotEmpty &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return board[0][2];
    }

    // Check for draw
    bool isFull = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          isFull = false;
          break;
        }
      }
    }

    return isFull ? 'draw' : 'ongoing';
  }

  void _resetGame() {
    setState(() {
      gameBoard = List.generate(3, (_) => List.filled(3, ''));
      currentPlayer = 'X';
      isGameActive = true;
      gameStatus = '';
      winningCombination = null;
      isAiThinking = false;
    });
  }

  void _resetScores() {
    setState(() {
      player1Score = 0;
      player2Score = 0;
      drawCount = 0;
    });
    _resetGame();
  }

  void _showGameResultModal() {
    Timer(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              gameStatus.contains('Draw') ? 'Game Draw!' : 'Game Over!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gameStatus,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Current Scores',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                player1Name,
                                style: TextStyle(fontSize: 10.sp),
                              ),
                              Text(
                                player1Score.toString(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Draws',
                                style: TextStyle(fontSize: 10.sp),
                              ),
                              Text(
                                drawCount.toString(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getWarningColor(true),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                player2Name,
                                style: TextStyle(fontSize: 10.sp),
                              ),
                              Text(
                                player2Score.toString(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      AppTheme.lightTheme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/main-menu');
                },
                child: Text(
                  'Main Menu',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetGame();
                },
                child: Text(
                  'Play Again',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Game Menu',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3.h),
              _buildMenuOption(
                icon: 'home',
                title: 'Main Menu',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/main-menu');
                },
              ),
              _buildMenuOption(
                icon: 'restart_alt',
                title: 'New Game',
                onTap: () {
                  Navigator.of(context).pop();
                  _resetGame();
                },
              ),
              _buildMenuOption(
                icon: 'refresh',
                title: 'Reset Scores',
                onTap: () {
                  Navigator.of(context).pop();
                  _resetScores();
                },
              ),
              _buildMenuOption(
                icon: 'settings',
                title: 'Settings',
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigate to settings
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showSettings() {
    // Placeholder for settings functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings coming soon!',
          style: TextStyle(fontSize: 12.sp),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'TicTacToe Master',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/main-menu'),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showMenu,
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 2.h),

              // Player indicator
              PlayerIndicatorWidget(
                currentPlayer: currentPlayer,
                player1Name: player1Name,
                player2Name: player2Name,
                player1Score: player1Score,
                player2Score: player2Score,
                isGameActive: isGameActive,
              ),

              // Game status
              GameStatusWidget(
                gameStatus: gameStatus,
                currentPlayer: currentPlayer,
                isGameActive: isGameActive,
              ),

              // AI thinking indicator
              AiThinkingWidget(
                isVisible: isAiThinking,
              ),

              // Game grid
              AnimatedBuilder(
                animation: _celebrationAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: !isGameActive && winningCombination != null
                        ? _celebrationAnimation.value
                        : 1.0,
                    child: GameGridWidget(
                      gameBoard: gameBoard,
                      onCellTap: _onCellTap,
                      winningCombination: winningCombination,
                      isGameActive: isGameActive,
                    ),
                  );
                },
              ),

              SizedBox(height: 2.h),

              // Action buttons
              GameActionButtonsWidget(
                onResetGame: _resetGame,
                onShowMenu: _showMenu,
                onShowSettings: _showSettings,
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
