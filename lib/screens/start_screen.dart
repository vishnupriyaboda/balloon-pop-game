import 'package:flutter/material.dart';

import '../models/game_stats.dart';
import 'game_screen.dart';

/// Title screen - uses Scale, Fade, Slide and Rotation transitions.
class StartScreen extends StatefulWidget {
  static const route = '/';
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _spin;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..forward();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _logoScale = CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut));
    _titleFade = CurvedAnimation(
        parent: _intro, curve: const Interval(0.4, 0.8, curve: Curves.easeIn));
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _intro, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _intro.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scale transition (bounce-in) + Rotation transition (spinning star)
              ScaleTransition(
                scale: _logoScale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _spin,
                      child: const Icon(Icons.wb_sunny,
                          size: 150, color: Colors.amber),
                    ),
                    const Icon(Icons.celebration,
                        size: 70, color: Colors.deepOrange),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Fade transition
              FadeTransition(
                opacity: _titleFade,
                child: const Text(
                  'BALLOON POP',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _titleFade,
                child: Text('Best score: ${GameStats.best}',
                    style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 40),
              // Slide transition
              SlideTransition(
                position: _buttonSlide,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    textStyle: const TextStyle(fontSize: 22),
                  ),
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, GameScreen.route),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('PLAY'),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _titleFade,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Tap the balloons before they float away.\nYou have 3 lives!',
                    textAlign: TextAlign.center,
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
