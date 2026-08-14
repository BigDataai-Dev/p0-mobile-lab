enum ExportTarget { messaging, social, archive }

class VideoExportPolicy {
  const VideoExportPolicy({
    required this.target,
    required this.maxWidth,
    required this.maxHeight,
    required this.videoBitrateKbps,
    required this.audioBitrateKbps,
  });

  final ExportTarget target;
  final int maxWidth;
  final int maxHeight;
  final int videoBitrateKbps;
  final int audioBitrateKbps;

  static const messaging = VideoExportPolicy(
    target: ExportTarget.messaging,
    maxWidth: 1280,
    maxHeight: 720,
    videoBitrateKbps: 1800,
    audioBitrateKbps: 96,
  );

  static const social = VideoExportPolicy(
    target: ExportTarget.social,
    maxWidth: 1920,
    maxHeight: 1080,
    videoBitrateKbps: 3500,
    audioBitrateKbps: 128,
  );

  static const archive = VideoExportPolicy(
    target: ExportTarget.archive,
    maxWidth: 3840,
    maxHeight: 2160,
    videoBitrateKbps: 9000,
    audioBitrateKbps: 192,
  );

  static VideoExportPolicy forTarget(ExportTarget target) => switch (target) {
        ExportTarget.messaging => messaging,
        ExportTarget.social => social,
        ExportTarget.archive => archive,
      };
}
