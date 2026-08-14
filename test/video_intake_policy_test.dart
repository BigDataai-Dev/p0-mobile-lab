import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/video_intake_policy.dart';

void main() {
  const policy = VideoIntakePolicy();

  test('accepts a normal supported video', () {
    final decision = policy.evaluate(
      filename: 'clip.mp4',
      bytes: 120 * 1024 * 1024,
      durationSeconds: 180,
    );
    expect(decision.accepted, isTrue);
  });

  test('rejects unsupported formats', () {
    final decision = policy.evaluate(
      filename: 'clip.avi',
      bytes: 10 * 1024 * 1024,
      durationSeconds: 30,
    );
    expect(decision.accepted, isFalse);
    expect(decision.reason, 'unsupported_format');
  });

  test('rejects oversized files', () {
    final decision = policy.evaluate(
      filename: 'clip.mov',
      bytes: 3 * 1024 * 1024 * 1024,
      durationSeconds: 300,
    );
    expect(decision.accepted, isFalse);
    expect(decision.reason, 'file_too_large');
  });
}
