import 'package:flutter/material.dart';

import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/start_screen.dart';

void main() => runApp(const BalloonPopApp());

class BalloonPopApp extends StatelessWidget {
  const BalloonPopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balloon Pop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      initialRoute: StartScreen.route,
      routes: {
        StartScreen.route: (_) => const StartScreen(),
        GameScreen.route: (_) => const GameScreen(),
        GameOverScreen.route: (_) => const GameOverScreen(),
      },
    );
  }
}
