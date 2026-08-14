import 'monetization_policy.dart';

class UtilityUsageSession {
  const UtilityUsageSession({
    this.completedUsesToday = 0,
    this.rewardedBonusUsesRemaining = 0,
    this.premium = false,
  });

  final int completedUsesToday;
  final int rewardedBonusUsesRemaining;
  final bool premium;

  MonetizationAction action(
    MonetizationPolicy policy,
  ) =>
      policy.decide(
        completedUsesToday: completedUsesToday,
        premium: premium,
        rewardedBonusUsesRemaining: rewardedBonusUsesRemaining,
      );

  UtilityUsageSession completeUse() {
    final bonusWasUsed = !premium &&
        completedUsesToday >= defaultUtilityMonetizationPolicy.freeUsesPerDay &&
        rewardedBonusUsesRemaining > 0;
    return UtilityUsageSession(
      completedUsesToday: completedUsesToday + 1,
      rewardedBonusUsesRemaining: bonusWasUsed
          ? rewardedBonusUsesRemaining - 1
          : rewardedBonusUsesRemaining,
      premium: premium,
    );
  }

  UtilityUsageSession grantRewardedBonus({int uses = 1}) {
    if (premium || uses <= 0) return this;
    return UtilityUsageSession(
      completedUsesToday: completedUsesToday,
      rewardedBonusUsesRemaining: rewardedBonusUsesRemaining + uses,
      premium: premium,
    );
  }

  UtilityUsageSession upgradeToPremium() => UtilityUsageSession(
        completedUsesToday: completedUsesToday,
        rewardedBonusUsesRemaining: rewardedBonusUsesRemaining,
        premium: true,
      );

  Map<String, Object> toAnalytics() => <String, Object>{
        'completed_uses_today': completedUsesToday,
        'rewarded_bonus_remaining': rewardedBonusUsesRemaining,
        'premium': premium,
      };
}
