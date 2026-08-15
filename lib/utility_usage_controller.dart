import 'monetization_policy.dart';
import 'utility_access_state.dart';
import 'utility_usage_session.dart';
import 'utility_usage_store.dart';

class UtilityUsageController {
  UtilityUsageController({
    UtilityUsageStore? store,
    this.policy = defaultUtilityMonetizationPolicy,
  }) : store = store ?? UtilityUsageStore();

  final UtilityUsageStore store;
  final MonetizationPolicy policy;

  UtilityUsageSession? _session;

  UtilityUsageSession? get session => _session;
  bool get ready => _session != null;

  UtilityAccessState get accessState {
    final current = _session;
    if (current == null) {
      return UtilityAccessState.evaluate(
        policy: policy,
        completedUsesToday: 0,
        premium: false,
        rewardedBonusUsesRemaining: 0,
      );
    }
    return UtilityAccessState.evaluate(
      policy: policy,
      completedUsesToday: current.completedUsesToday,
      premium: current.premium,
      rewardedBonusUsesRemaining: current.rewardedBonusUsesRemaining,
    );
  }

  Future<UtilityUsageSession> bootstrap(DateTime now) async {
    final loaded = await store.load(currentDayKey: dayKey(now));
    _session = loaded;
    return loaded;
  }

  Future<UtilityUsageSession> recordCompletedUse() async {
    final current = _requireSession();
    final action = current.action(policy);
    if (action == MonetizationAction.requirePremium) {
      return current;
    }
    final next = current.completeUse(policy);
    await store.save(next);
    _session = next;
    return next;
  }

  Future<UtilityUsageSession> grantRewardedBonus() async {
    final current = _requireSession();
    final next = current.grantRewardedBonus(uses: policy.rewardedBonusUses);
    await store.save(next);
    _session = next;
    return next;
  }

  Future<UtilityUsageSession> upgradeToPremium() async {
    final current = _requireSession();
    final next = current.upgradeToPremium();
    await store.save(next);
    _session = next;
    return next;
  }

  UtilityUsageSession _requireSession() {
    final current = _session;
    if (current == null) {
      throw StateError('UtilityUsageController.bootstrap must run first.');
    }
    return current;
  }

  static String dayKey(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
