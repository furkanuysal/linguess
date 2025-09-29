class AchievementProgress {
  final int current;
  final int target;

  const AchievementProgress({required this.current, required this.target});

  double get ratio => target == 0 ? 0 : current / target;
  int get percent => (ratio * 100).clamp(0, 100).round();
}
