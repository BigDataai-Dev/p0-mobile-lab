import 'package:flutter/material.dart';
import 'experiment_analytics.dart';
import 'video_compression_session.dart';
import 'video_compressor.dart';

class VideoCompressPrototypeScreen extends StatefulWidget {
  const VideoCompressPrototypeScreen({super.key});
  @override
  State<VideoCompressPrototypeScreen> createState() => _VideoCompressPrototypeScreenState();
}

class _VideoCompressPrototypeScreenState extends State<VideoCompressPrototypeScreen> {
  static const analytics = DebugExperimentAnalytics();
  VideoCompressionSession session = const VideoCompressionSession();

  static const sample = VideoSource(
    path: 'sample_4k_trip.mp4',
    sizeBytes: 248000000,
    durationMs: 84000,
    width: 3840,
    height: 2160,
  );

  @override
  void initState() {
    super.initState();
    analytics.track('video_compress_open');
  }

  void loadSample() {
    analytics.track('video_source_selected', {
      'size_bytes': sample.sizeBytes,
      'duration_ms': sample.durationMs,
      'width': sample.width,
      'height': sample.height,
    });
    setState(() => session = session.selectSource(sample));
  }

  void selectPreset(CompressionPreset preset) {
    analytics.track('compression_preset_selected', {'preset': preset.name});
    setState(() => session = session.selectPreset(preset));
  }

  void simulateCompression() {
    if (!session.canStart) return;
    analytics.track('compression_started', {
      'preset': session.preset.name,
      'input_size_bytes': sample.sizeBytes,
    });

    final factor = switch (session.preset) {
      CompressionPreset.small => 0.28,
      CompressionPreset.balanced => 0.43,
      CompressionPreset.highQuality => 0.64,
    };
    final compressed = CompressedVideo(
      path: 'sample_4k_trip_compressed.mp4',
      sizeBytes: (sample.sizeBytes * factor).round(),
      width: session.preset == CompressionPreset.small ? 1280 : 1920,
      height: session.preset == CompressionPreset.small ? 720 : 1080,
    );

    setState(() => session = session.start().complete(compressed));
    analytics.track('compression_completed', {
      'preset': session.preset.name,
      'input_size_bytes': sample.sizeBytes,
      'output_size_bytes': compressed.sizeBytes,
      'reduction_percent': ((1 - (compressed.sizeBytes / sample.sizeBytes)) * 100).round(),
    });
  }

  void simulateExport() {
    final result = session.result;
    if (result == null) return;
    analytics.track('compressed_video_exported', {
      'preset': session.preset.name,
      'output_size_bytes': result.sizeBytes,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prototype export completed')),
    );
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
            onSelectionChanged: (value) => selectPreset(value.first),
          ),
          const SizedBox(height: 20),
          if (result != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${mb(sample.sizeBytes)} → ${mb(result.sizeBytes)} · ${((session.reductionRatio ?? 0) * 100).round()}% smaller'),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: simulateExport,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Export result'),
                    ),
                  ],
                ),
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
