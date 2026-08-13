import 'package:flutter/material.dart';
import 'candidates.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('P0 Mobile Lab')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Ranked candidates', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          for (final candidate in candidates)
            Card(
              child: ListTile(
                title: Text(candidate.name),
                subtitle: Text(candidate.problem),
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
