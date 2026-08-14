import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/video_value_estimate.dart';

void main() {
  test('reports strong meaningful savings', () {
    const estimate = VideoValueEstimate(
      originalBytes: 100000000,
      estimatedBytes: 42000000,
    );

    expect(estimate.savedBytes, 58000000);
    expect(estimate.savingsPercent, 58);
    expect(estimate.meaningful, isTrue);
    expect(estimate.headline, 'Strong size reduction');
  });

  test('does not report negative savings', () {
    const estimate = VideoValueEstimate(
      originalBytes: 100,
      estimatedBytes: 140,
    );

    expect(estimate.savedBytes, 0);
    expect(estimate.savingsPercent, 0);
    expect(estimate.meaningful, isFalse);
  });
}
