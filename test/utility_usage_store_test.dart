import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/utility_usage_session.dart';
import 'package:p0_mobile_lab/utility_usage_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists and restores usage for the same day', () async {
    final store = UtilityUsageStore(storageKey: 'test.usage');
    const session = UtilityUsageSession(
      completedUsesToday: 2,
      rewardedBonusUsesRemaining: 1,
      premium: false,
      dayKey: '2026-08-15',
    );

    await store.save(session);
    final restored = await store.load(currentDayKey: '2026-08-15');

    expect(restored.completedUsesToday, 2);
    expect(restored.rewardedBonusUsesRemaining, 1);
    expect(restored.dayKey, '2026-08-15');
  });

  test('rolls usage forward with a fresh daily quota', () async {
    final store = UtilityUsageStore(storageKey: 'test.usage');
    await store.save(const UtilityUsageSession(
      completedUsesToday: 4,
      rewardedBonusUsesRemaining: 2,
      dayKey: '2026-08-14',
    ));

    final restored = await store.load(currentDayKey: '2026-08-15');

    expect(restored.completedUsesToday, 0);
    expect(restored.rewardedBonusUsesRemaining, 0);
    expect(restored.dayKey, '2026-08-15');
  });

  test('recovers safely from corrupt storage', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'test.usage': '{bad json',
    });
    final store = UtilityUsageStore(storageKey: 'test.usage');

    final restored = await store.load(currentDayKey: '2026-08-15');

    expect(restored.completedUsesToday, 0);
    expect(restored.dayKey, '2026-08-15');
  });
}
