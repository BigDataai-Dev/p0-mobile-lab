import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/video_backend_capabilities.dart';
import 'package:p0_mobile_lab/video_picker_contract.dart';
import 'package:p0_mobile_lab/video_selection_controller.dart';
import 'package:p0_mobile_lab/video_selection_state.dart';
import 'package:p0_mobile_lab/video_workflow_gate.dart';

void main() {
  const productionBackend = VideoBackendCapabilities(
    canReadMetadata: true,
    canTranscode: true,
    canReportProgress: true,
    canCancel: true,
    canExport: true,
    runsOnDevice: true,
  );

  VideoSelectionState readyState() {
    final video = PickedVideo(
      path: '/tmp/sample.mp4',
      name: 'sample.mp4',
      sizeBytes: 10 * 1024 * 1024,
      durationSeconds: 30,
    );
    return VideoSelectionState.fromResult(
      VideoSelectionResult(
        selection: VideoPickerResult.selected(video),
        intakeDecision: const VideoIntakeDecision.accepted(),
      ),
    );
  }

  test('prototype mode allows an eligible selection before backend is production ready', () {
    const gate = VideoWorkflowGate(mode: VideoWorkflowMode.prototype);
    final result = gate.evaluate(
      selection: readyState(),
      backend: prototypeVideoBackend,
    );
    expect(result.allowed, isTrue);
  });

  test('production mode blocks incomplete backend capabilities', () {
    const gate = VideoWorkflowGate(mode: VideoWorkflowMode.production);
    final result = gate.evaluate(
      selection: readyState(),
      backend: prototypeVideoBackend,
    );
    expect(result.allowed, isFalse);
    expect(result.blockers, contains('Backend missing: transcode'));
    expect(result.blockers, contains('Backend missing: export'));
  });

  test('production mode allows ready selection and complete backend', () {
    const gate = VideoWorkflowGate(mode: VideoWorkflowMode.production);
    final result = gate.evaluate(
      selection: readyState(),
      backend: productionBackend,
    );
    expect(result.allowed, isTrue);
    expect(result.blockers, isEmpty);
  });
}
