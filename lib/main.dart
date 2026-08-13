import 'package:flutter/material.dart';

void main() => runApp(const MobileLabApp());

class MobileLabApp extends StatelessWidget {
  const MobileLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF4D6BFE)),
      home: const LabHomeScreen(),
    );
  }
}

class LabHomeScreen extends StatelessWidget {
  const LabHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P0 Mobile Lab')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _ExperimentCard(
            title: 'Experiment 001',
            subtitle: 'Candidate selection in progress',
          ),
          SizedBox(height: 12),
          _ExperimentCard(
            title: 'Shared Core',
            subtitle: 'Provider-neutral app foundation',
          ),
        ],
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
