import 'video_backend_capabilities.dart';
import 'video_selection_state.dart';
import 'video_workflow_gate.dart';

class VideoWorkflowStatus {
  const VideoWorkflowStatus({
    required this.mode,
    required this.allowed,
    required this.label,
    required this.details,
  });

  final VideoWorkflowMode mode;
  final bool allowed;
  final String label;
  final List<String> details;

  factory VideoWorkflowStatus.from({
    required VideoWorkflowMode mode,
    required VideoSelectionState selection,
    required VideoBackendCapabilities backend,
  }) {
    final decision = VideoWorkflowGate(mode: mode).evaluate(
      selection: selection,
      backend: backend,
    );

    final label = decision.allowed
        ? mode == VideoWorkflowMode.prototype
            ? 'Prototype flow ready'
            : 'Production flow ready'
        : mode == VideoWorkflowMode.prototype
            ? 'Prototype blocked'
            : 'Not production ready';

    return VideoWorkflowStatus(
      mode: mode,
      allowed: decision.allowed,
      label: label,
      details: decision.allowed
          ? List.unmodifiable([
              if (mode == VideoWorkflowMode.prototype)
                'Compression may still use a simulated backend.',
              if (mode == VideoWorkflowMode.production)
                'Selection and backend capabilities satisfy the release gate.',
            ])
          : decision.blockers,
    );
  }
}
