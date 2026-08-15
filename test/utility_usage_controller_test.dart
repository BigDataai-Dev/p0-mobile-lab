import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/monetization_policy.dart';
import 'package:p0_mobile_lab/utility_usage_controller.dart';
import 'package:p0_mobile_lab/utility_usage_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('bootstrap creates a deterministic daily session', () async {
    final controller = UtilityUsageController(
      store: UtilityUsageStore(storageKey: 'test.usage'),
    );

    final session = await controller.bootstrap(DateTime(2026, 8, 15, 9, 30));

    expect(session.dayKey, '2026-08-15');
    expect(controller.ready, isTrue);
    expect(controller.accessState.freeUsesRemaining, 3);
  });

  test('completed uses persist and advance the free quota', () async {
    final store = UtilityUsageStore(storageKey: 'test.persisted');
    final controller = UtilityUsageController(store: store);
    await controller.bootstrap(DateTime(2026, 8, 15));

    await controller.recordCompletedUse();
    await controller.recordCompletedUse();

    final restored = UtilityUsageController(store: store);
    await restored.bootstrap(DateTime(2026, 8, 15));
    expect(restored.session?.completedUsesToday, 2);
    expect(restored.accessState.freeUsesRemaining, 1);
  });

  test('rewarded offer grants one immediately usable bonus', () async {
    const policy = MonetizationPolicy(freeUsesPerDay: 1, rewardedBonusUses: 1);
    final controller = UtilityUsageController(
      store: UtilityUsageStore(storageKey: 'test.rewarded'),
      policy: policy,
    );
    await controller.bootstrap(DateTime(2026, 8, 15));

    await controller.recordCompletedUse();
    expect(controller.accessState.action, MonetizationAction.offerRewarded);

    await controller.grantRewardedBonus();
    expect(controller.accessState.action, MonetizationAction.allowFree);
    expect(controller.accessState.usingRewardedBonus, isTrue);

    await controller.recordCompletedUse();
    expect(controller.session?.rewardedBonusUsesRemaining, 0);
    expect(controller.accessState.action, MonetizationAction.requirePremium);
  });

  test('next day resets non-premium quota through the store', () async {
    final store = UtilityUsageStore(storageKey: 'test.reset');
    final controller = UtilityUsageController(store: store);
    await controller.bootstrap(DateTime(2026, 8, 15));
    await controller.recordCompletedUse();

    final nextDay = UtilityUsageController(store: store);
    await nextDay.bootstrap(DateTime(2026, 8, 16));

    expect(nextDay.session?.completedUsesToday, 0);
    expect(nextDay.session?.dayKey, '2026-08-16');
  });
}
