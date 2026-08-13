import 'experiment.dart';

class ExperimentMetrics {
  const ExperimentMetrics({
    required this.installs,
    required this.activationRate,
    required this.dayOneRetention,
    required this.daySevenRetention,
    required this.payerConversion,
    required this.adRevenuePerUser,
    required this.organicShare,
  });

  final int installs;
  final double activationRate;
  final double dayOneRetention;
  final double daySevenRetention;
  final double payerConversion;
  final double adRevenuePerUser;
  final double organicShare;
}

class ExperimentDecision {
  const ExperimentDecision({required this.status, required this.reasons});

  final ExperimentStatus status;
  final List<String> reasons;
}

class ExperimentEvaluator {
  const ExperimentEvaluator({
    this.minimumSample = 250,
    this.minimumActivation = 0.55,
    this.minimumDayOneRetention = 0.22,
    this.minimumDaySevenRetention = 0.08,
    this.minimumOrganicShare = 0.35,
  });

  final int minimumSample;
  final double minimumActivation;
  final double minimumDayOneRetention;
  final double minimumDaySevenRetention;
  final double minimumOrganicShare;

  ExperimentDecision evaluate(ExperimentMetrics metrics) {
    if (metrics.installs < minimumSample) {
      return const ExperimentDecision(
        status: ExperimentStatus.live,
        reasons: ['Not enough installs for a kill/scale decision yet.'],
      );
    }

    final misses = <String>[];
    if (metrics.activationRate < minimumActivation) {
      misses.add('Activation is below the minimum target.');
    }
    if (metrics.dayOneRetention < minimumDayOneRetention) {
      misses.add('Day-1 retention is below the minimum target.');
    }
    if (metrics.daySevenRetention < minimumDaySevenRetention) {
      misses.add('Day-7 retention is below the minimum target.');
    }
    if (metrics.organicShare < minimumOrganicShare) {
      misses.add('Organic acquisition share is too weak.');
    }

    if (misses.length >= 2) {
      return ExperimentDecision(status: ExperimentStatus.killed, reasons: misses);
    }

    if (misses.isNotEmpty) {
      return ExperimentDecision(
        status: ExperimentStatus.validating,
        reasons: misses,
      );
    }

    return const ExperimentDecision(
      status: ExperimentStatus.live,
      reasons: ['Core activation, retention and organic signals clear the gate.'],
    );
  }
}
