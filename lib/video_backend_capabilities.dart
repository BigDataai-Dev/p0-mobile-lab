class VideoBackendCapabilities {
  const VideoBackendCapabilities({
    required this.canReadMetadata,
    required this.canTranscode,
    required this.canReportProgress,
    required this.canCancel,
    required this.canExport,
    required this.runsOnDevice,
  });

  final bool canReadMetadata;
  final bool canTranscode;
  final bool canReportProgress;
  final bool canCancel;
  final bool canExport;
  final bool runsOnDevice;

  bool get productionReady =>
      canReadMetadata &&
      canTranscode &&
      canReportProgress &&
      canCancel &&
      canExport &&
      runsOnDevice;

  List<String> get missingRequirements {
    final missing = <String>[];
    if (!canReadMetadata) missing.add('metadata');
    if (!canTranscode) missing.add('transcode');
    if (!canReportProgress) missing.add('progress');
    if (!canCancel) missing.add('cancel');
    if (!canExport) missing.add('export');
    if (!runsOnDevice) missing.add('on-device processing');
    return missing;
  }
}

const prototypeVideoBackend = VideoBackendCapabilities(
  canReadMetadata: true,
  canTranscode: false,
  canReportProgress: false,
  canCancel: false,
  canExport: false,
  runsOnDevice: true,
);
