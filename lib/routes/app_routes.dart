import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/game_board/game_board.dart';
import '../presentation/player_setup/player_setup.dart';
import '../presentation/ai_difficulty_selection/ai_difficulty_selection.dart';
import '../presentation/main_menu/main_menu.dart';
import '../presentation/game_results_modal/game_results_modal.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String gameBoard = '/game-board';
  static const String playerSetup = '/player-setup';
  static const String aiDifficultySelection = '/ai-difficulty-selection';
  static const String mainMenu = '/main-menu';
  static const String gameResultsModal = '/game-results-modal';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    gameBoard: (context) => const GameBoard(),
    playerSetup: (context) => const PlayerSetup(),
    aiDifficultySelection: (context) => const AiDifficultySelection(),
    mainMenu: (context) => const MainMenu(),
    gameResultsModal: (context) => const GameResultsModal(),
    // TODO: Add your other routes here
  };
}
