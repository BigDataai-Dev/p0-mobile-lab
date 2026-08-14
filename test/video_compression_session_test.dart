import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/video_compression_session.dart';
import 'package:p0_mobile_lab/video_compressor.dart';

void main() {
  const source = VideoSource(
    path: '/tmp/source.mp4',
    sizeBytes: 1000,
    durationMs: 12000,
    width: 1920,
    height: 1080,
  );

  test('compression session progresses from source selection to completion', () {
    var session = const VideoCompressionSession();
    session = session.selectSource(source);
    expect(session.stage, CompressionStage.ready);
    expect(session.canStart, isTrue);

    session = session.start().updateProgress(0.4);
    expect(session.stage, CompressionStage.compressing);
    expect(session.progress, 0.4);

    session = session.complete(
      const CompressedVideo(
        path: '/tmp/output.mp4',
        sizeBytes: 600,
        width: 1280,
        height: 720,
      ),
    );
    expect(session.stage, CompressionStage.completed);
    expect(session.reductionRatio, closeTo(0.4, 0.001));
  });

  test('progress is clamped to a safe range', () {
    final session = const VideoCompressionSession()
        .selectSource(source)
        .start()
        .updateProgress(4);
    expect(session.progress, 1);
  });
}
