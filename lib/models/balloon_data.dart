import 'package:flutter/material.dart';

/// Describes one balloon: where it starts, how fast it floats, its colour.
class BalloonData {
  final int id;
  final double x; // 0.0 (left) .. 1.0 (right)
  final Duration floatDuration;
  final Color color;
  final double wobble; // how many sway cycles during the flight

  const BalloonData({
    required this.id,
    required this.x,
    required this.floatDuration,
    required this.color,
    required this.wobble,
  });
}
