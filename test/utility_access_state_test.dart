import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/utility_access_state.dart';

void main() {
  test('free user can run while daily quota remains', () {
    final state = UtilityAccessState.evaluate(
      completedUsesToday: 1,
      premium: false,
      rewardedBonusUsesRemaining: 0,
    );

    expect(state.canRunImmediately, isTrue);
    expect(state.freeUsesRemaining, 2);
    expect(state.badge, '2 free today');
    expect(state.primaryActionLabel, 'Compress video');
  });

  test('rewarded ad is offered after free quota', () {
    final state = UtilityAccessState.evaluate(
      completedUsesToday: 3,
      premium: false,
      rewardedBonusUsesRemaining: 0,
    );

    expect(state.canRunImmediately, isFalse);
    expect(state.badge, 'Watch ad for 1 more');
    expect(state.primaryActionLabel, 'Watch ad for 1 more');
  });

  test('granted bonus can run immediately', () {
    final state = UtilityAccessState.evaluate(
      completedUsesToday: 3,
      premium: false,
      rewardedBonusUsesRemaining: 1,
    );

    expect(state.canRunImmediately, isTrue);
    expect(state.usingRewardedBonus, isTrue);
    expect(state.badge, '1 bonus ready');
    expect(state.primaryActionLabel, 'Compress video');
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
