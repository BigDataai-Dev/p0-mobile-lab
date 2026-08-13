import 'experiment.dart';

class ValidationGate {
  const ValidationGate({
    required this.minimumScore,
    required this.minimumOrganicIntent,
    required this.minimumMonetization,
  });

  final double minimumScore;
  final int minimumOrganicIntent;
  final int minimumMonetization;

  bool passes(Experiment experiment) =>
      experiment.score >= minimumScore &&
      experiment.organicIntent >= minimumOrganicIntent &&
      experiment.monetization >= minimumMonetization;

  List<String> failures(Experiment experiment) {
    final values = <String>[];
    if (experiment.score < minimumScore) {
      values.add('score ${experiment.score.toStringAsFixed(2)} < $minimumScore');
    }
    if (experiment.organicIntent < minimumOrganicIntent) {
      values.add('organic intent ${experiment.organicIntent} < $minimumOrganicIntent');
    }
    if (experiment.monetization < minimumMonetization) {
      values.add('monetization ${experiment.monetization} < $minimumMonetization');
    }
    return values;
  }
}

const defaultBuildGate = ValidationGate(
  minimumScore: 6.5,
  minimumOrganicIntent: 7,
  minimumMonetization: 6,
);
