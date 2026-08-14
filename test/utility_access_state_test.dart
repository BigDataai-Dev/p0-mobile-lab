import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/utility_access_state.dart';

void main() {
  test('free user can run while daily quota remains', () {
    final state = UtilityAccessState.evaluate(
      completedUsesToday: 1,
      premium: false,
      rewardedBonusUsesRemaining: 1,
    );

    expect(state.canRunImmediately, isTrue);
    expect(state.freeUsesRemaining, 2);
    expect(state.badge, '2 free today');
    expect(state.primaryActionLabel, 'Compress video');
  });

  test('rewarded state exposes bonus CTA after free quota', () {
    final state = UtilityAccessState.evaluate(
      completedUsesToday: 3,
      premium: false,
      rewardedBonusUsesRemaining: 1,
    );

    expect(state.canRunImmediately, isFalse);
    expect(state.badge, 'Bonus available');
    expect(state.primaryActionLabel, 'Watch ad for 1 more');
  });

  test('premium bypasses usage limits', () {
    final state = UtilityAccessState.evaluate(
      completedUsesToday: 99,
      premium: true,
      rewardedBonusUsesRemaining: 0,
    );

    expect(state.canRunImmediately, isTrue);
    expect(state.badge, 'Premium');
    expect(state.primaryActionLabel, 'Compress video');
  });
}
