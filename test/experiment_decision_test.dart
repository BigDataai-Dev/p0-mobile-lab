import 'package:flutter_test/flutter_test.dart';
import 'package:p0_mobile_lab/candidates.dart';
import 'package:p0_mobile_lab/experiment_decision.dart';

void main() {
  test('best build candidate is the highest scoring experiment that passes', () {
    final best = bestBuildCandidate(initialCandidates);
    expect(best, isNotNull);
    expect(best!.experiment.id, 'video-compress');
    expect(best.shouldBuild, isTrue);
  });

  test('blocked candidates explain their failures', () {
    final decisions = evaluateExperiments(initialCandidates);
    final ringtone = decisions.firstWhere(
      (decision) => decision.experiment.id == 'ringtone-maker',
    );
    expect(ringtone.shouldBuild, isFalse);
    expect(ringtone.reasons, isNotEmpty);
  });

  test('decisions remain sorted by weighted score', () {
    final decisions = evaluateExperiments(initialCandidates);
    for (var i = 1; i < decisions.length; i++) {
      expect(
        decisions[i - 1].experiment.score,
        greaterThanOrEqualTo(decisions[i].experiment.score),
      );
    }
  });
}
