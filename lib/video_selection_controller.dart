import 'experiment_analytics.dart';
import 'video_intake_policy.dart';
import 'video_picker_contract.dart';

class VideoSelectionResult {
  const VideoSelectionResult({
    required this.selection,
    this.intakeDecision,
  });

  final VideoSelection selection;
  final VideoIntakeDecision? intakeDecision;

  bool get ready => selection.succeeded && intakeDecision?.accepted == true;
}

class VideoSelectionController {
  const VideoSelectionController({
    required this.picker,
    this.policy = const VideoIntakePolicy(),
    this.analytics = const DebugExperimentAnalytics(),
  });

  final VideoPicker picker;
  final VideoIntakePolicy policy;
  final ExperimentAnalytics analytics;

  Future<VideoSelectionResult> select() async {
    analytics.track('video_pick_started');
    try {
      final video = await picker.pickVideo();
      if (video == null) {
        analytics.track('video_pick_cancelled');
        return VideoSelectionResult(
          selection: VideoSelection.cancelled(),
        );
      }

      final decision = policy.evaluate(
        filename: video.fileName,
        bytes: video.sizeBytes,
        durationSeconds: video.duration.inSeconds,
      );

      analytics.track(
        decision.accepted ? 'video_pick_accepted' : 'video_pick_rejected',
        {
          'file_name': video.fileName,
          'size_bytes': video.sizeBytes,
          'duration_seconds': video.duration.inSeconds,
          'reason': decision.reason,
        },
      );

      return VideoSelectionResult(
        selection: VideoSelection.selected(video),
        intakeDecision: decision,
      );
    } catch (error) {
      analytics.track('video_pick_failed', {'error': error.toString()});
      return VideoSelectionResult(
        selection: VideoSelection.failed(error),
      );
    }
  }
}
