/// Keeps the best score in memory while the app is running.
class GameStats {
  static int best = 0;

  static void submit(int score) {
    if (score > best) best = score;
  }
}
