import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_background.dart';
import './widgets/app_logo_widget.dart';
import './widgets/credits_overlay.dart';
import './widgets/game_mode_button.dart';
import './widgets/player_info_card.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _playerName = 'Guest Player';
  String _lastDifficulty = 'Medium';
  bool _showCredits = false;
  bool _hasPlayedBefore = false;

  // Mock game statistics
  final Map<String, dynamic> _gameStats = {
    'totalGames': 0,
    'wins': 0,
    'losses': 0,
    'draws': 0,
    'winStreak': 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPlayerData();
    _loadGameStats();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  Future<void> _loadPlayerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _playerName = prefs.getString('player_name') ?? 'Guest Player';
        _lastDifficulty = prefs.getString('last_difficulty') ?? 'Medium';
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadGameStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _gameStats['totalGames'] = prefs.getInt('total_games') ?? 0;
        _gameStats['wins'] = prefs.getInt('wins') ?? 0;
        _gameStats['losses'] = prefs.getInt('losses') ?? 0;
        _gameStats['draws'] = prefs.getInt('draws') ?? 0;
        _gameStats['winStreak'] = prefs.getInt('win_streak') ?? 0;
        _hasPlayedBefore = _gameStats['totalGames'] > 0;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _savePlayerName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('player_name', name);
      setState(() {
        _playerName = name;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _handlePlayVsAI() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/ai-difficulty-selection');
  }

  void _handlePlayVsHuman() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/player-setup');
  }

  void _handleStatistics() {
    HapticFeedback.lightImpact();
    if (!_hasPlayedBefore) {
      _showFirstGameDialog();
    } else {
      // Navigate to statistics screen (not implemented in this scope)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Statistics: ${_gameStats['wins']} wins, ${_gameStats['losses']} losses, ${_gameStats['draws']} draws'),
          behavior: SnackBarBehavior.floating));
    }
  }

  void _handleSettings() {
    HapticFeedback.lightImpact();
    // Navigate to settings screen (not implemented in this scope)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Settings screen coming soon!'),
        behavior: SnackBarBehavior.floating));
  }

  void _handleEditPlayerName() {
    _showPlayerNameDialog();
  }

  void _showPlayerNameDialog() {
    final TextEditingController controller =
        TextEditingController(text: _playerName);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Edit Player Name',
                  style: AppTheme.lightTheme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      hintText: 'Enter your name', labelText: 'Player Name'),
                  maxLength: 20,
                  textCapitalization: TextCapitalization.words),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      final newName = controller.text.trim();
                      if (newName.isNotEmpty) {
                        _savePlayerName(newName);
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save')),
              ]);
        });
  }

  void _showFirstGameDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('No Games Played Yet',
                  style: AppTheme.lightTheme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                CustomIconWidget(
                    iconName: 'sports_esports',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.h),
                SizedBox(height: 2.h),
                Text(
                    'Start your TicTacToe journey! Play your first game to unlock statistics and track your progress.',
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                    textAlign: TextAlign.center),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Maybe Later')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _handlePlayVsAI();
                    },
                    child: const Text('Play Your First Game')),
              ]);
        });
  }

  void _handlePullDownGesture() {
    setState(() {
      _showCredits = true;
    });
  }

  void _dismissCredits() {
    setState(() {
      _showCredits = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      // Animated background
      const AnimatedBackground(),

      // Main content
      SafeArea(
          child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                  onPanDown: (details) {
                    // Check if pull-down gesture from top
                    if (details.globalPosition.dy < 10.h) {
                      _handlePullDownGesture();
                    }
                  },
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Column(children: [
                            SizedBox(height: 4.h),

                            // App logo and title
                            const AppLogoWidget(),

                            SizedBox(height: 6.h),

                            // Game mode buttons
                            GameModeButton(
                                title: 'Play vs AI',
                                iconName: 'smart_toy',
                                onTap: _handlePlayVsAI,
                                badge: _lastDifficulty,
                                badgeColor:
                                    AppTheme.lightTheme.colorScheme.secondary),

                            GameModeButton(
                                title: 'Play vs Human',
                                iconName: 'people',
                                onTap: _handlePlayVsHuman),

                            GameModeButton(
                                title: 'Statistics',
                                iconName: 'bar_chart',
                                onTap: _handleStatistics,
                                badge: _hasPlayedBefore
                                    ? '${_gameStats['totalGames']}'
                                    : null,
                                badgeColor: AppTheme.getSuccessColor(true)),

                            GameModeButton(
                                title: 'Settings',
                                iconName: 'settings',
                                onTap: _handleSettings),

                            SizedBox(height: 4.h),

                            // Player info card
                            PlayerInfoCard(
                                playerName: _playerName,
                                onEditTap: _handleEditPlayerName),

                            SizedBox(height: 4.h),

                            // Quick start hint
                            Container(
                                width: 85.w,
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                    color: AppTheme
                                        .lightTheme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary
                                            .withValues(alpha: 0.2))),
                                child: Row(children: [
                                  CustomIconWidget(
                                      iconName: 'lightbulb',
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      size: 2.5.h),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                      child: Text(
                                          'Tip: Long-press game mode buttons for quick options!',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: AppTheme.lightTheme
                                                      .colorScheme.primary,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                ])),

                            SizedBox(height: 2.h),
                          ])))))),

      // Credits overlay
      if (_showCredits) CreditsOverlay(onDismiss: _dismissCredits),
    ]));
  }
}
