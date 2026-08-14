import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/experiment_analytics.dart';
import 'package:p0_mobile_lab/video_picker_contract.dart';
import 'package:p0_mobile_lab/video_selection_controller.dart';
import 'package:p0_mobile_lab/video_selection_state.dart';

class _Picker implements VideoPicker {
  const _Picker(this.video);
  final PickedVideo? video;

  @override
  Future<PickedVideo?> pickVideo() async => video;
}

void main() {
  test('coordinator reaches ready for an eligible picked video', () async {
    const video = PickedVideo(
      uri: 'memory://clip.mp4',
      fileName: 'clip.mp4',
      sizeBytes: 120000000,
      duration: Duration(seconds: 45),
      mimeType: 'video/mp4',
    );
    final coordinator = VideoSelectionCoordinator(
      VideoSelectionController(
        picker: const _Picker(video),
        analytics: const DebugExperimentAnalytics(),
      ),
    );

    final state = await coordinator.select();

    expect(state.phase, VideoSelectionPhase.ready);
    expect(state.canCompress, isTrue);
    expect(state.video?.fileName, 'clip.mp4');
  });

  test('coordinator records cancellation without a compressible source', () async {
    final coordinator = VideoSelectionCoordinator(
      VideoSelectionController(
        picker: const _Picker(null),
        analytics: const DebugExperimentAnalytics(),
      ),
    );

    final state = await coordinator.select();

    expect(state.phase, VideoSelectionPhase.cancelled);
    expect(state.canCompress, isFalse);
  });

  test('coordinator rejects unsupported video extensions', () async {
    const video = PickedVideo(
      uri: 'memory://clip.txt',
      fileName: 'clip.txt',
      sizeBytes: 1000,
      duration: Duration(seconds: 5),
      mimeType: 'text/plain',
    );
    final coordinator = VideoSelectionCoordinator(
      VideoSelectionController(
        picker: const _Picker(video),
        analytics: const DebugExperimentAnalytics(),
      ),
    );

    final state = await coordinator.select();

    expect(state.phase, VideoSelectionPhase.rejected);
    expect(state.canCompress, isFalse);
  });
}
