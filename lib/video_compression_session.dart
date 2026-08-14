import 'video_compressor.dart';

enum CompressionStage { idle, ready, compressing, completed, failed, cancelled }

class VideoCompressionSession {
  const VideoCompressionSession({
    this.stage = CompressionStage.idle,
    this.source,
    this.preset = CompressionPreset.balanced,
    this.progress = 0,
    this.result,
    this.error,
  });

  final CompressionStage stage;
  final VideoSource? source;
  final CompressionPreset preset;
  final double progress;
  final CompressedVideo? result;
  final String? error;

  bool get canStart => source != null && stage != CompressionStage.compressing;

  double? get reductionRatio {
    final original = source?.sizeBytes;
    final compressed = result?.sizeBytes;
    if (original == null || compressed == null || original <= 0) return null;
    return 1 - (compressed / original);
  }

  VideoCompressionSession selectSource(VideoSource nextSource) =>
      VideoCompressionSession(
        stage: CompressionStage.ready,
        source: nextSource,
        preset: preset,
      );

  VideoCompressionSession selectPreset(CompressionPreset nextPreset) =>
      VideoCompressionSession(
        stage: source == null ? CompressionStage.idle : CompressionStage.ready,
        source: source,
        preset: nextPreset,
      );

  VideoCompressionSession start() => VideoCompressionSession(
        stage: CompressionStage.compressing,
        source: source,
        preset: preset,
      );

  VideoCompressionSession updateProgress(double nextProgress) =>
      VideoCompressionSession(
        stage: CompressionStage.compressing,
        source: source,
        preset: preset,
        progress: nextProgress.clamp(0.0, 1.0),
      );

  VideoCompressionSession complete(CompressedVideo video) =>
      VideoCompressionSession(
        stage: CompressionStage.completed,
        source: source,
        preset: preset,
        progress: 1,
        result: video,
      );

  VideoCompressionSession fail(Object cause) => VideoCompressionSession(
        stage: CompressionStage.failed,
        source: source,
        preset: preset,
        progress: progress,
        error: cause.toString(),
      );

  VideoCompressionSession cancel() => VideoCompressionSession(
        stage: CompressionStage.cancelled,
        source: source,
        preset: preset,
        progress: progress,
      );
}
