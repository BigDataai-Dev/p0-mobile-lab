class VideoSource {
  const VideoSource({
    required this.path,
    required this.sizeBytes,
    required this.durationMs,
    required this.width,
    required this.height,
  });

  final String path;
  final int sizeBytes;
  final int durationMs;
  final int width;
  final int height;
}

enum CompressionPreset { small, balanced, highQuality }

class CompressionProgress {
  const CompressionProgress(this.value);

  final double value;
}

class CompressedVideo {
  const CompressedVideo({
    required this.path,
    required this.sizeBytes,
    required this.width,
    required this.height,
  });

  final String path;
  final int sizeBytes;
  final int width;
  final int height;
}

abstract interface class VideoCompressor {
  Stream<CompressionProgress> progress();

  Future<CompressedVideo> compress({
    required VideoSource source,
    required CompressionPreset preset,
  });

  Future<void> cancel();
}
