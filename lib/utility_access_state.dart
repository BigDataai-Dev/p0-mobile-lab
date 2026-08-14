import 'monetization_policy.dart';

class UtilityAccessState {
  const UtilityAccessState({
    required this.action,
    required this.completedUsesToday,
    required this.freeUsesPerDay,
    required this.rewardedBonusUsesRemaining,
    required this.premium,
  });

  final MonetizationAction action;
  final int completedUsesToday;
  final int freeUsesPerDay;
  final int rewardedBonusUsesRemaining;
  final bool premium;

  int get freeUsesRemaining =>
      (freeUsesPerDay - completedUsesToday).clamp(0, freeUsesPerDay);

  bool get canRunImmediately =>
      action == MonetizationAction.allowFree || premium;

  String get badge {
    if (premium) return 'Premium';
    switch (action) {
      case MonetizationAction.allowFree:
        return '$freeUsesRemaining free today';
      case MonetizationAction.offerRewarded:
        return 'Bonus available';
      case MonetizationAction.requirePremium:
        return 'Daily limit reached';
    }
  }

  String get primaryActionLabel {
    if (premium || action == MonetizationAction.allowFree) {
      return 'Compress video';
    }
    if (action == MonetizationAction.offerRewarded) {
      return 'Watch ad for 1 more';
    }
    return 'Unlock unlimited';
  }

  factory UtilityAccessState.evaluate({
    MonetizationPolicy policy = defaultUtilityMonetizationPolicy,
    required int completedUsesToday,
    required bool premium,
    required int rewardedBonusUsesRemaining,
  }) {
    final action = policy.decide(
      completedUsesToday: completedUsesToday,
      premium: premium,
      rewardedBonusUsesRemaining: rewardedBonusUsesRemaining,
    );
    return UtilityAccessState(
      action: action,
      completedUsesToday: completedUsesToday,
      freeUsesPerDay: policy.freeUsesPerDay,
      rewardedBonusUsesRemaining: rewardedBonusUsesRemaining,
      premium: premium,
    );
  }
}
