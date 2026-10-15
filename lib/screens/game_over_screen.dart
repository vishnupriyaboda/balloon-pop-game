import 'package:flutter/material.dart';

import '../models/game_stats.dart';
import 'game_screen.dart';
import 'start_screen.dart';

/// Game over screen - score counts up, card scales + fades in.
class GameOverScreen extends StatefulWidget {
  static const route = '/game-over';
  const GameOverScreen({super.key});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = (ModalRoute.of(context)?.settings.arguments as int?) ?? 0;
    final isBest = score > 0 && score >= GameStats.best;

    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('GAME OVER',
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.red)),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: score),
                      duration: const Duration(milliseconds: 1200),
                      builder: (_, value, __) => Text('Score: $value',
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Text(isBest ? 'New best score!' : 'Best: ${GameStats.best}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, GameScreen.route),
                      icon: const Icon(Icons.replay),
                      label: const Text('Play Again'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, StartScreen.route),
                      child: const Text('Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
