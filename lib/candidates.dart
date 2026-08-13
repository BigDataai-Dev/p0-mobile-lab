import 'experiment.dart';

const initialCandidates = <Experiment>[
  Experiment(
    id: 'photo-cleanup',
    name: 'Photo Cleanup',
    problem: 'Remove unwanted objects and distractions from personal photos.',
    organicIntent: 8,
    repeatUse: 6,
    monetization: 7,
    buildSimplicity: 5,
  ),
  Experiment(
    id: 'video-compress',
    name: 'Video Compress',
    problem: 'Shrink videos before messaging, upload, or storage.',
    organicIntent: 8,
    repeatUse: 7,
    monetization: 6,
    buildSimplicity: 7,
  ),
  Experiment(
    id: 'ringtone-maker',
    name: 'Ringtone Maker',
    problem: 'Turn owned audio clips into phone-ready ringtone files.',
    organicIntent: 7,
    repeatUse: 4,
    monetization: 5,
    buildSimplicity: 8,
  ),
];

List<Experiment> rankedCandidates() {
  final values = List<Experiment>.of(initialCandidates);
  values.sort((a, b) => b.score.compareTo(a.score));
  return values;
}
