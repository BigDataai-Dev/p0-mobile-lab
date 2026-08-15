import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/monetization_policy.dart';
import 'package:p0_mobile_lab/utility_usage_session.dart';

void main() {
  const policy = MonetizationPolicy(
    freeUsesPerDay: 2,
    rewardedBonusUses: 1,
  );

  test('free quota becomes rewarded offer after configured limit', () {
    var session = const UtilityUsageSession(dayKey: '2026-08-14');
    expect(session.action(policy), MonetizationAction.allowFree);

    session = session.completeUse(policy).completeUse(policy);
    expect(session.action(policy), MonetizationAction.offerRewarded);

    session = session.grantRewardedBonus();
    expect(session.action(policy), MonetizationAction.allowFree);

    session = session.completeUse(policy);
    expect(session.rewardedBonusUsesRemaining, 0);
    expect(session.action(policy), MonetizationAction.requirePremium);
  });

  test('premium bypasses quota and rewarded state', () {
    final session = const UtilityUsageSession(
      completedUsesToday: 50,
      rewardedBonusUsesRemaining: 0,
      dayKey: '2026-08-14',
    ).upgradeToPremium();

    expect(session.action(policy), MonetizationAction.allowFree);
    expect(session.completeUse(policy).completedUsesToday, 51);
  });

  test('new day resets free and rewarded usage for non premium users', () {
    const previous = UtilityUsageSession(
      completedUsesToday: 4,
      rewardedBonusUsesRemaining: 2,
      dayKey: '2026-08-14',
    );

    final next = previous.forDay('2026-08-15');
    expect(next.completedUsesToday, 0);
    expect(next.rewardedBonusUsesRemaining, 0);
    expect(next.dayKey, '2026-08-15');
  });

  test('session json roundtrip preserves monetization state', () {
    const original = UtilityUsageSession(
      completedUsesToday: 2,
      rewardedBonusUsesRemaining: 1,
      premium: true,
      dayKey: '2026-08-14',
    );

    final restored = UtilityUsageSession.fromJson(original.toJson());
    expect(restored.completedUsesToday, 2);
    expect(restored.rewardedBonusUsesRemaining, 1);
    expect(restored.premium, isTrue);
    expect(restored.dayKey, '2026-08-14');
  });
}
