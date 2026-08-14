import 'package:flutter/material.dart';
import 'video_compression_session.dart';
import 'video_compressor.dart';

class VideoCompressPrototypeScreen extends StatefulWidget {
  const VideoCompressPrototypeScreen({super.key});
  @override
  State<VideoCompressPrototypeScreen> createState() => _VideoCompressPrototypeScreenState();
}

class _VideoCompressPrototypeScreenState extends State<VideoCompressPrototypeScreen> {
  VideoCompressionSession session = const VideoCompressionSession();

  static const sample = VideoSource(
    path: 'sample_4k_trip.mp4',
    sizeBytes: 248000000,
    durationMs: 84000,
    width: 3840,
    height: 2160,
  );

  void loadSample() => setState(() => session = session.selectSource(sample));

  void simulateCompression() {
    if (!session.canStart) return;
    final factor = switch (session.preset) {
      CompressionPreset.small => 0.28,
      CompressionPreset.balanced => 0.43,
      CompressionPreset.highQuality => 0.64,
    };
    setState(() {
      session = session.start().complete(
        CompressedVideo(
          path: 'sample_4k_trip_compressed.mp4',
          sizeBytes: (sample.sizeBytes * factor).round(),
          width: session.preset == CompressionPreset.small ? 1280 : 1920,
          height: session.preset == CompressionPreset.small ? 720 : 1080,
        ),
      );
    });
  }

  String mb(int bytes) => '${(bytes / 1000000).toStringAsFixed(1)} MB';

  @override
  Widget build(BuildContext context) {
    final result = session.result;
    return Scaffold(
      appBar: AppBar(title: const Text('Video Compress Prototype')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Compress a large video in three taps', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.video_file_outlined),
              title: Text(session.source?.path ?? 'Choose a video'),
              subtitle: Text(session.source == null ? 'Load demo source' : '${mb(sample.sizeBytes)} · 4K · 1m24s'),
              onTap: loadSample,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<CompressionPreset>(
            segments: const [
              ButtonSegment(value: CompressionPreset.small, label: Text('Small')),
              ButtonSegment(value: CompressionPreset.balanced, label: Text('Balanced')),
              ButtonSegment(value: CompressionPreset.highQuality, label: Text('Quality')),
            ],
            selected: {session.preset},
            onSelectionChanged: (value) => setState(() => session = session.selectPreset(value.first)),
          ),
          const SizedBox(height: 20),
          if (result != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text('${mb(sample.sizeBytes)} → ${mb(result.sizeBytes)} · ${((session.reductionRatio ?? 0) * 100).round()}% smaller'),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: session.canStart ? simulateCompression : null,
            icon: const Icon(Icons.compress_rounded),
            label: const Text('Compress'),
          ),
        ],
      ),
    );
  }
}
