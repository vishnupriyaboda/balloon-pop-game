# Balloon Pop - Flutter Animation Game

**Lab Experiment 8** - User Interface Design using Flutter (JNTUK R23)
a) Add animations to UI elements using Flutter's animation framework
b) Experiment with different types of animations (fade, slide, etc.)

## Gameplay
Balloons float up the screen. Tap them to pop before they escape.
You have 3 lives. The game gets faster and the background colour changes every 10 points.

## Where each animation is used
| Animation | Type | Location |
|---|---|---|
| Logo bounce-in | `ScaleTransition` (explicit) | start_screen.dart |
| Spinning sun | `RotationTransition` (explicit) | start_screen.dart |
| Title text | `FadeTransition` (explicit) | start_screen.dart |
| Play button | `SlideTransition` (explicit) | start_screen.dart |
| Balloon floating / sway / tilt | `AnimationController` + `AnimatedBuilder` | balloon_widget.dart |
| Balloon pop | `ScaleTransition` + `FadeTransition` | balloon_widget.dart |
| Score change | `AnimatedSwitcher` | game_screen.dart |
| Lives (hearts) | `AnimatedScale`, `AnimatedOpacity` (implicit) | game_screen.dart |
| Level background colour | `TweenAnimationBuilder` (implicit) | game_screen.dart |
| Pause overlay | `AnimatedSwitcher` + fade | game_screen.dart |
| Game over card + score count-up | Scale/Fade + `TweenAnimationBuilder<int>` | game_over_screen.dart |

## Project structure
```
balloon_pop_game/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── models/ (balloon_data.dart, game_stats.dart)
│   ├── screens/ (start_screen, game_screen, game_over_screen)
│   └── widgets/balloon_widget.dart
└── test/widget_test.dart
```

## How to run
```
flutter create .     # once, generates android/ios/web folders
flutter pub get
flutter run
```
Requires Flutter 3.27+ (uses `Color.withValues`). On older Flutter, replace
`withValues(alpha: x)` with `withOpacity(x)`.
