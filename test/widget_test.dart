import 'package:flutter_test/flutter_test.dart';
import 'package:balloon_pop_game/main.dart';

void main() {
  testWidgets('Start screen shows title and play button', (tester) async {
    await tester.pumpWidget(const BalloonPopApp());
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('BALLOON POP'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
