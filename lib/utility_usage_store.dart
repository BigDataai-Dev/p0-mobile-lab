import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'utility_usage_session.dart';

class UtilityUsageStore {
  UtilityUsageStore({this.storageKey = 'p0.utility_usage_session.v1'});

  final String storageKey;

  Future<UtilityUsageSession> load({required String currentDayKey}) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return UtilityUsageSession(dayKey: currentDayKey);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return UtilityUsageSession(dayKey: currentDayKey);
      }
      return UtilityUsageSession.fromJson(decoded).forDay(currentDayKey);
    } catch (_) {
      return UtilityUsageSession(dayKey: currentDayKey);
    }
  }

  Future<void> save(UtilityUsageSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storageKey, jsonEncode(session.toJson()));
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
