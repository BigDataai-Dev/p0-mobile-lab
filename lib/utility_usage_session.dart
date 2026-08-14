import 'monetization_policy.dart';

class UtilityUsageSession {
  const UtilityUsageSession({
    this.completedUsesToday = 0,
    this.rewardedBonusUsesRemaining = 0,
    this.premium = false,
    this.dayKey,
  });

  final int completedUsesToday;
  final int rewardedBonusUsesRemaining;
  final bool premium;
  final String? dayKey;

  MonetizationAction action(
    MonetizationPolicy policy,
  ) =>
      policy.decide(
        completedUsesToday: completedUsesToday,
        premium: premium,
        rewardedBonusUsesRemaining: rewardedBonusUsesRemaining,
      );

  UtilityUsageSession forDay(String currentDayKey) {
    if (dayKey == null || dayKey == currentDayKey || premium) {
      return dayKey == currentDayKey
          ? this
          : UtilityUsageSession(
              completedUsesToday: premium ? completedUsesToday : 0,
              rewardedBonusUsesRemaining:
                  premium ? rewardedBonusUsesRemaining : 0,
              premium: premium,
              dayKey: currentDayKey,
            );
    }
    return UtilityUsageSession(premium: premium, dayKey: currentDayKey);
  }

  UtilityUsageSession completeUse(MonetizationPolicy policy) {
    final bonusWasUsed = !premium &&
        completedUsesToday >= policy.freeUsesPerDay &&
        rewardedBonusUsesRemaining > 0;
    return UtilityUsageSession(
      completedUsesToday: completedUsesToday + 1,
      rewardedBonusUsesRemaining: bonusWasUsed
          ? rewardedBonusUsesRemaining - 1
          : rewardedBonusUsesRemaining,
      premium: premium,
      dayKey: dayKey,
    );
  }

  UtilityUsageSession grantRewardedBonus({int uses = 1}) {
    if (premium || uses <= 0) return this;
    return UtilityUsageSession(
      completedUsesToday: completedUsesToday,
      rewardedBonusUsesRemaining: rewardedBonusUsesRemaining + uses,
      premium: premium,
      dayKey: dayKey,
    );
  }

  UtilityUsageSession upgradeToPremium() => UtilityUsageSession(
        completedUsesToday: completedUsesToday,
        rewardedBonusUsesRemaining: rewardedBonusUsesRemaining,
        premium: true,
        dayKey: dayKey,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'completed_uses_today': completedUsesToday,
        'rewarded_bonus_remaining': rewardedBonusUsesRemaining,
        'premium': premium,
        'day_key': dayKey,
      };

  factory UtilityUsageSession.fromJson(Map<String, Object?> json) {
    return UtilityUsageSession(
      completedUsesToday: json['completed_uses_today'] as int? ?? 0,
      rewardedBonusUsesRemaining:
          json['rewarded_bonus_remaining'] as int? ?? 0,
      premium: json['premium'] as bool? ?? false,
      dayKey: json['day_key'] as String?,
    );
  }

  Map<String, Object> toAnalytics() => <String, Object>{
        'completed_uses_today': completedUsesToday,
        'rewarded_bonus_remaining': rewardedBonusUsesRemaining,
        'premium': premium,
        if (dayKey != null) 'day_key': dayKey!,
      };
}
