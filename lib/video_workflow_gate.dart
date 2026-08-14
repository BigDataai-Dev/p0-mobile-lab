import 'video_backend_capabilities.dart';
import 'video_selection_state.dart';

enum VideoWorkflowMode { prototype, production }

class VideoWorkflowGate {
  const VideoWorkflowGate({required this.mode});

  final VideoWorkflowMode mode;

  VideoWorkflowDecision evaluate({
    required VideoSelectionState selection,
    required VideoBackendCapabilities backend,
  }) {
    final blockers = <String>[];

    if (!selection.canCompress) {
      blockers.add(selection.message ?? 'Select an eligible video');
    }

    if (mode == VideoWorkflowMode.production && !backend.productionReady) {
      blockers.addAll(
        backend.missingRequirements.map((item) => 'Backend missing: $item'),
      );
    }

    return VideoWorkflowDecision(
      allowed: blockers.isEmpty,
      blockers: List.unmodifiable(blockers),
    );
  }
}

class VideoWorkflowDecision {
  const VideoWorkflowDecision({
    required this.allowed,
    required this.blockers,
  });

  final bool allowed;
  final List<String> blockers;
}
