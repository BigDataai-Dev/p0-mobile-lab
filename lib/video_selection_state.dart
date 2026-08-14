import 'video_picker_contract.dart';
import 'video_selection_controller.dart';

enum VideoSelectionPhase {
  idle,
  selecting,
  ready,
  rejected,
  cancelled,
  failed,
}

class VideoSelectionState {
  const VideoSelectionState._({
    required this.phase,
    this.video,
    this.message,
  });

  const VideoSelectionState.idle()
      : this._(phase: VideoSelectionPhase.idle);

  const VideoSelectionState.selecting()
      : this._(phase: VideoSelectionPhase.selecting);

  final VideoSelectionPhase phase;
  final PickedVideo? video;
  final String? message;

  bool get canCompress => phase == VideoSelectionPhase.ready && video != null;

  factory VideoSelectionState.fromResult(VideoSelectionResult result) {
    if (result.selection.cancelledByUser) {
      return const VideoSelectionState._(
        phase: VideoSelectionPhase.cancelled,
        message: 'Selection cancelled',
      );
    }

    if (result.selection.error != null) {
      return VideoSelectionState._(
        phase: VideoSelectionPhase.failed,
        message: result.selection.error.toString(),
      );
    }

    final video = result.selection.video;
    if (video == null) {
      return const VideoSelectionState._(
        phase: VideoSelectionPhase.failed,
        message: 'No video returned by picker',
      );
    }

    final decision = result.intakeDecision;
    if (decision?.accepted != true) {
      return VideoSelectionState._(
        phase: VideoSelectionPhase.rejected,
        video: video,
        message: decision?.reason ?? 'Video is not eligible for compression',
      );
    }

    return VideoSelectionState._(
      phase: VideoSelectionPhase.ready,
      video: video,
      message: 'Ready to compress',
    );
  }
}

class VideoSelectionCoordinator {
  VideoSelectionCoordinator(this.controller);

  final VideoSelectionController controller;
  VideoSelectionState state = const VideoSelectionState.idle();

  Future<VideoSelectionState> select() async {
    state = const VideoSelectionState.selecting();
    final result = await controller.select();
    state = VideoSelectionState.fromResult(result);
    return state;
  }

  void reset() {
    state = const VideoSelectionState.idle();
  }
}
