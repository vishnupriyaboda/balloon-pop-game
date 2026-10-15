import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/balloon_data.dart';
import '../models/game_stats.dart';
import '../widgets/balloon_widget.dart';
import 'game_over_screen.dart';

/// Main game screen.
/// Animations used here:
///  * Balloons        -> see BalloonWidget (slide, rotate, scale, fade)
///  * Score           -> AnimatedSwitcher + ScaleTransition
///  * Lives (hearts)  -> AnimatedScale + AnimatedOpacity
///  * Background      -> TweenAnimationBuilder (colour changes every level)
///  * Pause overlay   -> AnimatedSwitcher + FadeTransition
class GameScreen extends StatefulWidget {
  static const route = '/game';
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int _maxLives = 3;
  static const List<Color> _balloonColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];
  static const List<Color> _levelColors = [
    Color(0xFF4FC3F7),
    Color(0xFF81C784),
    Color(0xFFFFB74D),
    Color(0xFFBA68C8),
    Color(0xFFE57373),
  ];

  final Random _rand = Random();
  final List<BalloonData> _balloons = [];
  Timer? _spawnTimer;

  int _score = 0;
  int _lives = _maxLives;
  int _nextId = 0;
  bool _paused = false;
  bool _over = false;

  int get _level => _score ~/ 10;

  @override
  void initState() {
    super.initState();
    _scheduleSpawn();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    super.dispose();
  }

  // ---------------- game logic ----------------

  void _scheduleSpawn() {
    _spawnTimer?.cancel();
    final ms = max(450, 1100 - _score * 15); // spawns faster as score grows
    _spawnTimer = Timer(Duration(milliseconds: ms), () {
      if (!mounted || _paused || _over) return;
      _spawn();
      _scheduleSpawn();
    });
  }

  void _spawn() {
    final base = max(2500, 6000 - _score * 60); // floats faster as score grows
    final data = BalloonData(
      id: _nextId++,
      x: _rand.nextDouble(),
      floatDuration: Duration(milliseconds: base + _rand.nextInt(1500)),
      color: _balloonColors[_rand.nextInt(_balloonColors.length)],
      wobble: 1 + _rand.nextInt(3).toDouble(),
    );
    setState(() => _balloons.add(data));
  }

  void _onPopped(int id) {
    if (_over) return;
    setState(() {
      _balloons.removeWhere((b) => b.id == id);
      _score++;
    });
  }

  void _onEscaped(int id) {
    if (_over) return;
    setState(() {
      _balloons.removeWhere((b) => b.id == id);
      _lives--;
    });
    if (_lives <= 0) _gameOver();
  }

  void _gameOver() {
    _over = true;
    _spawnTimer?.cancel();
    GameStats.submit(_score);
    Navigator.pushReplacementNamed(context, GameOverScreen.route,
        arguments: _score);
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _spawnTimer?.cancel();
    } else {
      _scheduleSpawn();
    }
  }

  // ---------------- UI ----------------

  Widget _hud() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Lives
          Row(
            children: List.generate(_maxLives, (i) {
              final alive = i < _lives;
              return AnimatedScale(
                scale: alive ? 1.0 : 0.6,
                duration: const Duration(milliseconds: 300),
                child: AnimatedOpacity(
                  opacity: alive ? 1.0 : 0.25,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.favorite,
                      color: Colors.red, size: 30),
                ),
              );
            }),
          ),
          const Spacer(),
          // Score with pop-in animation each time it changes
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              'Score: $_score',
              key: ValueKey(_score),
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          const Spacer(),
          Text('Lv ${_level + 1}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          IconButton(
            iconSize: 32,
            onPressed: _togglePause,
            icon: Icon(_paused ? Icons.play_circle : Icons.pause_circle),
          ),
        ],
      ),
    );
  }

  Widget _pauseOverlay() {
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _paused
            ? Container(
                key: const ValueKey('paused'),
                color: Colors.black54,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('PAUSED',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: _togglePause, child: const Text('Resume')),
                  ],
                ),
              )
            : const SizedBox.shrink(key: ValueKey('running')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColors[_level % _levelColors.length];

    return Scaffold(
      body: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: levelColor),
        duration: const Duration(milliseconds: 1200),
        builder: (context, color, child) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color ?? levelColor, Colors.white],
            ),
          ),
          child: child,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _hud(),
              Expanded(
                child: ClipRect(
                  child: Stack(
                    children: [
                      for (final b in _balloons)
                        Positioned.fill(
                          key: ValueKey(b.id),
                          child: BalloonWidget(
                            data: b,
                            paused: _paused,
                            onPopped: _onPopped,
                            onEscaped: _onEscaped,
                          ),
                        ),
                      _pauseOverlay(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
