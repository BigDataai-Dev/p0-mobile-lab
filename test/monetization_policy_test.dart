import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/monetization_policy.dart';

void main() {
  const policy = MonetizationPolicy(freeUsesPerDay: 3);

  test('allows usage inside the free daily quota', () {
    expect(
      policy.decide(
        completedUsesToday: 2,
        premium: false,
        rewardedBonusUsesRemaining: 0,
      ),
      MonetizationAction.allowFree,
    );
  });

  test('offers rewarded usage after quota when available', () {
    expect(
      policy.decide(
        completedUsesToday: 3,
        premium: false,
        rewardedBonusUsesRemaining: 1,
      ),
      MonetizationAction.offerRewarded,
    );
  });

  test('requires premium after free and rewarded quota', () {
    expect(
      policy.decide(
        completedUsesToday: 4,
        premium: false,
        rewardedBonusUsesRemaining: 0,
      ),
      MonetizationAction.requirePremium,
    );
  });

  test('premium bypasses usage limits', () {
    expect(
      policy.decide(
        completedUsesToday: 99,
        premium: true,
        rewardedBonusUsesRemaining: 0,
      ),
      MonetizationAction.allowFree,
    );
  });
}
