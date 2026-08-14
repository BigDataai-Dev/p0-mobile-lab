import 'video_compressor.dart';
import 'video_export_policy.dart';

class VideoSizeEstimate {
  const VideoSizeEstimate({
    required this.bytes,
    required this.reductionRatio,
  });

  final int bytes;
  final double reductionRatio;
}

class VideoSizeEstimator {
  const VideoSizeEstimator();

  VideoSizeEstimate estimate({
    required VideoSource source,
    required VideoExportPolicy policy,
    required CompressionPreset preset,
  }) {
    final presetMultiplier = switch (preset) {
      CompressionPreset.small => 0.72,
      CompressionPreset.balanced => 1.0,
      CompressionPreset.highQuality => 1.28,
    };

    final totalKbps =
        (policy.videoBitrateKbps + policy.audioBitrateKbps) * presetMultiplier;
    final durationSeconds = source.durationMs / 1000;
    final estimatedBytes = ((totalKbps * 1000 / 8) * durationSeconds).round();
    final cappedBytes = estimatedBytes.clamp(1, source.sizeBytes).toInt();
    final reduction = (1 - cappedBytes / source.sizeBytes).clamp(0.0, 1.0);

    return VideoSizeEstimate(bytes: cappedBytes, reductionRatio: reduction);
  }
}
