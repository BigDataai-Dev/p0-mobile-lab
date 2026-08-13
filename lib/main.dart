import 'package:flutter/material.dart';
import 'candidates.dart';
import 'validation_gate.dart';

void main() => runApp(const MobileLabApp());

class MobileLabApp extends StatelessWidget {
  const MobileLabApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF4D6BFE)),
        home: const LabHomeScreen(),
      );
}

class LabHomeScreen extends StatelessWidget {
  const LabHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final candidates = rankedCandidates();
    final passing = candidates.where(defaultBuildGate.passes).toList(growable: false);
    final winner = passing.isEmpty ? null : passing.first;

    return Scaffold(
      appBar: AppBar(title: const Text('P0 Mobile Lab')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Build decision', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    winner == null ? 'No candidate passes the build gate' : 'Build next: ${winner.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    winner == null
                        ? 'Keep validating. Do not spend implementation time yet.'
                        : '${winner.problem}\nScore ${winner.score.toStringAsFixed(2)} · Organic ${winner.organicIntent}/10 · Repeat ${winner.repeatUse}/10 · Monetization ${winner.monetization}/10 · Simplicity ${winner.buildSimplicity}/10',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Ranked candidates', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          for (final candidate in candidates)
            Card(
              child: ListTile(
                leading: Icon(
                  defaultBuildGate.passes(candidate)
                      ? Icons.check_circle_outline
                      : Icons.block_outlined,
                ),
                title: Text(candidate.name),
                subtitle: Text(
                  defaultBuildGate.passes(candidate)
                      ? '${candidate.problem}\nPasses build gate'
                      : '${candidate.problem}\nBlocked: ${defaultBuildGate.failures(candidate).join(' · ')}',
                ),
                trailing: Text(candidate.score.toStringAsFixed(1)),
              ),
            ),
          const SizedBox(height: 18),
          const Card(
            child: ListTile(
              title: Text('Shared Core'),
              subtitle: Text('Provider-neutral app foundation'),
            ),
          ),
        ],
      ),
    );
  }
}
