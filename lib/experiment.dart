class Experiment {
  const Experiment({
    required this.id,
    required this.name,
    required this.problem,
    required this.organicIntent,
    required this.repeatUse,
    required this.monetization,
    required this.buildSimplicity,
    this.status = ExperimentStatus.candidate,
  });

  final String id;
  final String name;
  final String problem;
  final int organicIntent;
  final int repeatUse;
  final int monetization;
  final int buildSimplicity;
  final ExperimentStatus status;

  double get score =>
      (organicIntent * 0.35) +
      (repeatUse * 0.20) +
      (monetization * 0.30) +
      (buildSimplicity * 0.15);
}

enum ExperimentStatus { candidate, validating, building, live, killed }
