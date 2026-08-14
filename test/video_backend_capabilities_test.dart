import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/video_backend_capabilities.dart';

void main() {
  test('prototype backend remains blocked from production', () {
    expect(prototypeVideoBackend.productionReady, isFalse);
    expect(prototypeVideoBackend.missingRequirements, contains('transcode'));
    expect(prototypeVideoBackend.missingRequirements, contains('export'));
  });

  test('fully capable on-device backend passes production gate', () {
    const backend = VideoBackendCapabilities(
      canReadMetadata: true,
      canTranscode: true,
      canReportProgress: true,
      canCancel: true,
      canExport: true,
      runsOnDevice: true,
    );

    expect(backend.productionReady, isTrue);
    expect(backend.missingRequirements, isEmpty);
  });
}
