abstract interface class ExperimentAnalytics {
  void track(String event, [Map<String, Object?> properties = const {}]);
}

class DebugExperimentAnalytics implements ExperimentAnalytics {
  const DebugExperimentAnalytics();

  @override
  void track(String event, [Map<String, Object?> properties = const {}]) {
    assert(() {
      // ignore: avoid_print
      print('[experiment] $event $properties');
      return true;
    }());
  }
}
