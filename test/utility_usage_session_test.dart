import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/monetization_policy.dart';
import 'package:p0_mobile_lab/utility_usage_session.dart';

void main() {
  const policy = MonetizationPolicy(
    freeUsesPerDay: 2,
    rewardedBonusUses: 1,
  );

  test('free quota becomes rewarded offer after configured limit', () {
    var session = const UtilityUsageSession();
    expect(session.action(policy), MonetizationAction.allowFree);

    session = session.completeUse(policy).completeUse(policy);
    expect(session.action(policy), MonetizationAction.requirePremium);

    session = session.grantRewardedBonus();
    expect(session.action(policy), MonetizationAction.offerRewarded);

    session = session.completeUse(policy);
    expect(session.rewardedBonusUsesRemaining, 0);
    expect(session.action(policy), MonetizationAction.requirePremium);
  });

  test('premium bypasses quota and rewarded state', () {
    final session = const UtilityUsageSession(
      completedUsesToday: 50,
      rewardedBonusUsesRemaining: 0,
    ).upgradeToPremium();

    expect(session.action(policy), MonetizationAction.allowFree);
    expect(session.completeUse(policy).completedUsesToday, 51);
  });
}
