enum MonetizationAction { allowFree, offerRewarded, requirePremium }

class MonetizationPolicy {
  const MonetizationPolicy({
    this.freeUsesPerDay = 3,
    this.rewardedBonusUses = 1,
    this.rewardedEnabled = true,
  });

  final int freeUsesPerDay;
  final int rewardedBonusUses;
  final bool rewardedEnabled;

  MonetizationAction decide({
    required int completedUsesToday,
    required bool premium,
    required int rewardedBonusUsesRemaining,
  }) {
    if (premium) return MonetizationAction.allowFree;
    if (completedUsesToday < freeUsesPerDay) {
      return MonetizationAction.allowFree;
    }
    if (rewardedEnabled && rewardedBonusUsesRemaining > 0) {
      return MonetizationAction.offerRewarded;
    }
    return MonetizationAction.requirePremium;
  }

  Map<String, Object> analyticsFields({
    required int completedUsesToday,
    required bool premium,
    required int rewardedBonusUsesRemaining,
  }) => <String, Object>{
        'completed_uses_today': completedUsesToday,
        'premium': premium,
        'rewarded_bonus_remaining': rewardedBonusUsesRemaining,
        'free_daily_quota': freeUsesPerDay,
      };
}

const defaultUtilityMonetizationPolicy = MonetizationPolicy();
