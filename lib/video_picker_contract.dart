class PickedVideo {
  const PickedVideo({
    required this.uri,
    required this.fileName,
    required this.sizeBytes,
    required this.duration,
    this.mimeType,
  });

  final String uri;
  final String fileName;
  final int sizeBytes;
  final Duration duration;
  final String? mimeType;
}

abstract interface class VideoPicker {
  Future<PickedVideo?> pickVideo();
}

class VideoSelection {
  const VideoSelection._({this.video, this.cancelled = false, this.error});

  final PickedVideo? video;
  final bool cancelled;
  final Object? error;

  bool get succeeded => video != null && error == null && !cancelled;

  factory VideoSelection.selected(PickedVideo video) => VideoSelection._(video: video);

  factory VideoSelection.cancelled() => const VideoSelection._(cancelled: true);

  factory VideoSelection.failed(Object error) => VideoSelection._(error: error);
}
