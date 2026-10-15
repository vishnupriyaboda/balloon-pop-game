import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../models/balloon_data.dart';

/// A single balloon with its own animations:
///  * float controller : slides the balloon from bottom to top (+ sway/rotate)
///  * pop controller   : ScaleTransition + FadeTransition when tapped
///
/// Must be placed as a child of `Positioned.fill` inside a Stack.
class BalloonWidget extends StatefulWidget {
  final BalloonData data;
  final bool paused;
  final ValueChanged<int> onPopped;
  final ValueChanged<int> onEscaped;

  const BalloonWidget({
    super.key,
    required this.data,
    required this.paused,
    required this.onPopped,
    required this.onEscaped,
  });

  @override
  State<BalloonWidget> createState() => _BalloonWidgetState();
}

class _BalloonWidgetState extends State<BalloonWidget>
    with TickerProviderStateMixin {
  static const double _width = 80;
  static const double _height = 130;

  late final AnimationController _float;
  late final AnimationController _pop;
  late final Animation<double> _popScale;
  late final Animation<double> _popFade;
  bool _popped = false;

  @override
  void initState() {
    super.initState();

    _float = AnimationController(vsync: this, duration: widget.data.floatDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_popped) {
          widget.onEscaped(widget.data.id);
        }
      });

    _pop = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onPopped(widget.data.id);
        }
      });

    _popScale = Tween<double>(begin: 1, end: 1.8)
        .animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));
    _popFade = Tween<double>(begin: 1, end: 0).animate(_pop);

    if (!widget.paused) _float.forward();
  }

  @override
  void didUpdateWidget(covariant BalloonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paused != oldWidget.paused && !_popped) {
      if (widget.paused) {
        _float.stop();
      } else {
        _float.forward();
      }
    }
  }

  @override
  void dispose() {
    _float.dispose();
    _pop.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_popped || widget.paused) return;
    _popped = true;
    _float.stop();
    _pop.forward();
  }

  Widget _balloonBody() {
    final color = widget.data.color;
    return SizedBox(
      width: _width,
      height: _height,
      child: Column(
        children: [
          Container(
            width: _width,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.elliptical(40, 50)),
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.5),
                radius: 0.9,
                colors: [Colors.white.withValues(alpha: 0.85), color, color],
                stops: const [0.0, 0.35, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
          ),
          // knot
          Container(width: 10, height: 8, color: color),
          // string
          Container(width: 2, height: 22, color: Colors.black38),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return AnimatedBuilder(
        animation: Listenable.merge([_float, _pop]),
        builder: (context, child) {
          final t = _float.value;
          final top = lerpDouble(h, -_height, t)!;
          final sway = sin(t * 2 * pi * widget.data.wobble);
          final left = (w - _width) * widget.data.x + sway * 14;

          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                child: GestureDetector(
                  onTap: _onTap,
                  child: Transform.rotate(
                    angle: sway * 0.12, // gentle rotation
                    child: FadeTransition(
                      opacity: _popFade,
                      child: ScaleTransition(scale: _popScale, child: child),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: _balloonBody(),
      );
    });
  }
}
