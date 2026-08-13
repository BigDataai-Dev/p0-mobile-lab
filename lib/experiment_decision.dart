import 'experiment.dart';
import 'validation_gate.dart';

class ExperimentDecision {
  const ExperimentDecision({
    required this.experiment,
    required this.shouldBuild,
    required this.reasons,
  });

  final Experiment experiment;
  final bool shouldBuild;
  final List<String> reasons;

  String get summary => shouldBuild
      ? '${experiment.name}: build candidate (${experiment.score.toStringAsFixed(2)})'
      : '${experiment.name}: blocked — ${reasons.join('; ')}';
}

List<ExperimentDecision> evaluateExperiments(
  Iterable<Experiment> experiments, {
  ValidationGate gate = defaultBuildGate,
}) {
  final decisions = experiments
      .map(
        (experiment) => ExperimentDecision(
          experiment: experiment,
          shouldBuild: gate.passes(experiment),
          reasons: gate.failures(experiment),
        ),
      )
      .toList()
    ..sort((a, b) => b.experiment.score.compareTo(a.experiment.score));
  return decisions;
}

ExperimentDecision? bestBuildCandidate(
  Iterable<Experiment> experiments, {
  ValidationGate gate = defaultBuildGate,
}) {
  for (final decision in evaluateExperiments(experiments, gate: gate)) {
    if (decision.shouldBuild) return decision;
  }
  return null;
}
