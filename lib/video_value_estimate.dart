class VideoValueEstimate {
  const VideoValueEstimate({
    required this.originalBytes,
    required this.estimatedBytes,
  });

  final int originalBytes;
  final int estimatedBytes;

  int get savedBytes => (originalBytes - estimatedBytes).clamp(0, originalBytes);

  double get savingsRatio =>
      originalBytes <= 0 ? 0 : savedBytes / originalBytes;

  int get savingsPercent => (savingsRatio * 100).round();

  bool get meaningful => savingsPercent >= 15;

  String get headline {
    if (originalBytes <= 0) return 'Choose a video to estimate savings';
    if (!meaningful) return 'Minimal size reduction expected';
    if (savingsPercent >= 60) return 'Large space saving';
    if (savingsPercent >= 35) return 'Strong size reduction';
    return 'Useful size reduction';
  }

  Map<String, Object> toAnalytics() => <String, Object>{
        'original_bytes': originalBytes,
        'estimated_bytes': estimatedBytes,
        'saved_bytes': savedBytes,
        'savings_percent': savingsPercent,
        'meaningful': meaningful,
      };
}
