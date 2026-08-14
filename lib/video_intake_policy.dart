class VideoIntakeDecision {
  const VideoIntakeDecision._({required this.accepted, required this.reason});

  final bool accepted;
  final String reason;

  const VideoIntakeDecision.accepted()
      : this._(accepted: true, reason: 'ready');

  const VideoIntakeDecision.rejected(String reason)
      : this._(accepted: false, reason: reason);
}

class VideoIntakePolicy {
  const VideoIntakePolicy({
    this.maxBytes = 2 * 1024 * 1024 * 1024,
    this.maxDurationSeconds = 60 * 60,
    this.supportedExtensions = const {'mp4', 'mov', 'm4v', 'webm'},
  });

  final int maxBytes;
  final int maxDurationSeconds;
  final Set<String> supportedExtensions;

  VideoIntakeDecision evaluate({
    required String filename,
    required int bytes,
    required int durationSeconds,
  }) {
    final extension = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';
    if (!supportedExtensions.contains(extension)) {
      return const VideoIntakeDecision.rejected('unsupported_format');
    }
    if (bytes <= 0) {
      return const VideoIntakeDecision.rejected('empty_file');
    }
    if (bytes > maxBytes) {
      return const VideoIntakeDecision.rejected('file_too_large');
    }
    if (durationSeconds <= 0) {
      return const VideoIntakeDecision.rejected('invalid_duration');
    }
    if (durationSeconds > maxDurationSeconds) {
      return const VideoIntakeDecision.rejected('video_too_long');
    }
    return const VideoIntakeDecision.accepted();
  }
}
