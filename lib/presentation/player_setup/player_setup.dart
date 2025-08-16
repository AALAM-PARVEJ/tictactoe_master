import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/game_preview_widget.dart';
import './widgets/player_config_card.dart';
import './widgets/quick_setup_presets.dart';

class PlayerSetup extends StatefulWidget {
  const PlayerSetup({Key? key}) : super(key: key);

  @override
  State<PlayerSetup> createState() => _PlayerSetupState();
}

class _PlayerSetupState extends State<PlayerSetup> {
  String _player1Name = 'Player 1';
  String _player1Symbol = 'X';
  String _player2Name = 'Player 2';
  String _player2Symbol = 'O';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedConfiguration();
  }

  Future<void> _loadSavedConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _player1Name = prefs.getString('player1_name') ?? 'Player 1';
        _player1Symbol = prefs.getString('player1_symbol') ?? 'X';
        _player2Name = prefs.getString('player2_name') ?? 'Player 2';
        _player2Symbol = prefs.getString('player2_symbol') ?? 'O';
      });
    } catch (e) {
      // Silent fail - use default values
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('player1_name', _player1Name);
      await prefs.setString('player1_symbol', _player1Symbol);
      await prefs.setString('player2_name', _player2Name);
      await prefs.setString('player2_symbol', _player2Symbol);
    } catch (e) {
      // Silent fail
    }
  }

  void _onPlayer1NameChanged(String name) {
    setState(() {
      _player1Name = name;
    });
  }

  void _onPlayer1SymbolChanged(String symbol) {
    setState(() {
      _player1Symbol = symbol;
      // Auto-switch player 2 symbol to avoid conflicts
      _player2Symbol = symbol == 'X' ? 'O' : 'X';
    });
  }

  void _onPlayer2NameChanged(String name) {
    setState(() {
      _player2Name = name;
    });
  }

  void _onPlayer2SymbolChanged(String symbol) {
    setState(() {
      _player2Symbol = symbol;
      // Auto-switch player 1 symbol to avoid conflicts
      _player1Symbol = symbol == 'X' ? 'O' : 'X';
    });
  }

  void _onPresetSelected(
      String p1Name, String p1Symbol, String p2Name, String p2Symbol) {
    setState(() {
      _player1Name = p1Name;
      _player1Symbol = p1Symbol;
      _player2Name = p2Name;
      _player2Symbol = p2Symbol;
    });
  }

  bool _isValidConfiguration() {
    return _player1Name.trim().isNotEmpty &&
        _player2Name.trim().isNotEmpty &&
        _player1Symbol != _player2Symbol &&
        _player1Name.trim().length <= 15 &&
        _player2Name.trim().length <= 15;
  }

  Future<void> _startGame() async {
    if (!_isValidConfiguration()) return;

    setState(() {
      _isLoading = true;
    });

    await _saveConfiguration();

    // Navigate to game board with player configuration
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/game-board',
        arguments: {
          'gameMode': 'human_vs_human',
          'player1Name': _player1Name,
          'player1Symbol': _player1Symbol,
          'player2Name': _player2Name,
          'player2Symbol': _player2Symbol,
        },
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Player Setup',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isValidConfiguration() ? _startGame : null,
            child: Text(
              'Done',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: _isValidConfiguration()
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Quick Setup Presets
              QuickSetupPresets(
                onPresetSelected: _onPresetSelected,
              ),

              SizedBox(height: 2.h),

              // Player 1 Configuration Card
              PlayerConfigCard(
                playerNumber: '1',
                initialName: _player1Name,
                initialSymbol: _player1Symbol,
                cardColor: AppTheme.lightTheme.colorScheme.primary,
                onNameChanged: _onPlayer1NameChanged,
                onSymbolChanged: _onPlayer1SymbolChanged,
                otherPlayerSymbol: _player2Symbol,
              ),

              SizedBox(height: 1.h),

              // Player 2 Configuration Card
              PlayerConfigCard(
                playerNumber: '2',
                initialName: _player2Name,
                initialSymbol: _player2Symbol,
                cardColor: AppTheme.lightTheme.colorScheme.secondary,
                onNameChanged: _onPlayer2NameChanged,
                onSymbolChanged: _onPlayer2SymbolChanged,
                otherPlayerSymbol: _player1Symbol,
              ),

              SizedBox(height: 2.h),

              // Game Preview
              GamePreviewWidget(
                player1Name: _player1Name,
                player1Symbol: _player1Symbol,
                player2Name: _player2Name,
                player2Symbol: _player2Symbol,
              ),

              SizedBox(height: 4.h),

              // Start Game Button
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: ElevatedButton(
                  onPressed: _isValidConfiguration() && !_isLoading
                      ? _startGame
                      : null,
                  style:
                      AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3);
                      }
                      return AppTheme.lightTheme.colorScheme.primary;
                    }),
                    minimumSize:
                        WidgetStateProperty.all(Size(double.infinity, 6.h)),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'play_arrow',
                              color: Colors.white,
                              size: 24,
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

              SizedBox(height: 4.h),

              // Configuration Status
              if (!_isValidConfiguration())
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.error
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Please ensure both players have valid names (1-15 characters) and different symbols.',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
