import 'package:flutter/material.dart';
import 'experiment_analytics.dart';
import 'video_compression_session.dart';
import 'video_compressor.dart';
import 'video_export_policy.dart';
import 'video_intake_policy.dart';
import 'video_size_estimator.dart';

class VideoCompressPrototypeScreen extends StatefulWidget {
  const VideoCompressPrototypeScreen({super.key});
  @override
  State<VideoCompressPrototypeScreen> createState() =>
      _VideoCompressPrototypeScreenState();
}

class _VideoCompressPrototypeScreenState
    extends State<VideoCompressPrototypeScreen> {
  static const analytics = DebugExperimentAnalytics();
  static const estimator = VideoSizeEstimator();
  static const intakePolicy = VideoIntakePolicy();

  VideoCompressionSession session = const VideoCompressionSession();
  ExportTarget exportTarget = ExportTarget.social;
  VideoIntakeDecision? lastIntakeDecision;

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
    final decision = intakePolicy.evaluate(
      filename: sample.path,
      bytes: sample.sizeBytes,
      durationSeconds: (sample.durationMs / 1000).ceil(),
    );

    analytics.track(
      decision.accepted ? 'video_source_accepted' : 'video_source_rejected',
      {
        'filename': sample.path,
        'size_bytes': sample.sizeBytes,
        'duration_ms': sample.durationMs,
        'width': sample.width,
        'height': sample.height,
        'reason': decision.reason,
      },
    );

    setState(() {
      lastIntakeDecision = decision;
      if (decision.accepted) {
        session = session.selectSource(sample);
      }
    });

    if (!decision.accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video rejected: ${decision.reason}')),
      );
    }
  }

  void selectPreset(CompressionPreset preset) {
    analytics.track('compression_preset_selected', {'preset': preset.name});
    setState(() => session = session.selectPreset(preset));
  }

  void selectExportTarget(ExportTarget target) {
    final policy = VideoExportPolicy.forTarget(target);
    analytics.track('export_target_selected', {
      'target': target.name,
      'max_width': policy.maxWidth,
      'max_height': policy.maxHeight,
      'video_bitrate_kbps': policy.videoBitrateKbps,
    });
    setState(() => exportTarget = target);
  }

  VideoSizeEstimate? currentEstimate() {
    final source = session.source;
    if (source == null) return null;
    return estimator.estimate(
      source: source,
      policy: VideoExportPolicy.forTarget(exportTarget),
      preset: session.preset,
    );
  }

  void simulateCompression() {
    final source = session.source;
    if (!session.canStart || source == null) return;
    final policy = VideoExportPolicy.forTarget(exportTarget);
    final estimate = estimator.estimate(
      source: source,
      policy: policy,
      preset: session.preset,
    );
    analytics.track('compression_started', {
      'preset': session.preset.name,
      'input_size_bytes': source.sizeBytes,
      'estimated_output_bytes': estimate.bytes,
      'target': exportTarget.name,
    });

    final compressed = CompressedVideo(
      path: 'sample_4k_trip_compressed.mp4',
      sizeBytes: estimate.bytes,
      width: policy.maxWidth,
      height: policy.maxHeight,
    );

    setState(() => session = session.start().complete(compressed));
    analytics.track('compression_completed', {
      'preset': session.preset.name,
      'input_size_bytes': source.sizeBytes,
      'output_size_bytes': compressed.sizeBytes,
      'reduction_percent':
          ((1 - (compressed.sizeBytes / source.sizeBytes)) * 100).round(),
    });
  }

  void simulateExport() {
    final result = session.result;
    if (result == null) return;
    final policy = VideoExportPolicy.forTarget(exportTarget);
    analytics.track('compressed_video_exported', {
      'preset': session.preset.name,
      'target': exportTarget.name,
      'output_size_bytes': result.sizeBytes,
      'max_width': policy.maxWidth,
      'max_height': policy.maxHeight,
      'video_bitrate_kbps': policy.videoBitrateKbps,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prototype export ready for ${exportTarget.name}'),
      ),
    );
  }

  String mb(int bytes) => '${(bytes / 1000000).toStringAsFixed(1)} MB';

  String targetLabel(ExportTarget target) => switch (target) {
        ExportTarget.messaging => 'Messaging',
        ExportTarget.social => 'Social',
        ExportTarget.archive => 'Archive',
      };

  @override
  Widget build(BuildContext context) {
    final result = session.result;
    final source = session.source;
    final policy = VideoExportPolicy.forTarget(exportTarget);
    final estimate = currentEstimate();
    return Scaffold(
      appBar: AppBar(title: const Text('Video Compress Prototype')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Compress a large video in three taps',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.video_file_outlined),
              title: Text(source?.path ?? 'Choose a video'),
              subtitle: Text(
                source == null
                    ? 'Load demo source'
                    : '${mb(source.sizeBytes)} · ${source.width}×${source.height} · ${(source.durationMs / 1000).round()}s',
              ),
              trailing: lastIntakeDecision?.accepted == true
                  ? const Icon(Icons.verified_rounded)
                  : null,
              onTap: loadSample,
            ),
          ),
          if (lastIntakeDecision != null) ...[
            const SizedBox(height: 8),
            Text(
              lastIntakeDecision!.accepted
                  ? 'Source validated locally · ready to compress'
                  : 'Source blocked · ${lastIntakeDecision!.reason}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          SegmentedButton<CompressionPreset>(
            segments: const [
              ButtonSegment(
                value: CompressionPreset.small,
                label: Text('Small'),
              ),
              ButtonSegment(
                value: CompressionPreset.balanced,
                label: Text('Balanced'),
              ),
              ButtonSegment(
                value: CompressionPreset.highQuality,
                label: Text('Quality'),
              ),
            ],
            selected: {session.preset},
            onSelectionChanged: (value) => selectPreset(value.first),
          ),
          const SizedBox(height: 20),
          Text('Export for', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SegmentedButton<ExportTarget>(
            segments: ExportTarget.values
                .map(
                  (target) => ButtonSegment(
                    value: target,
                    label: Text(targetLabel(target)),
                  ),
                )
                .toList(),
            selected: {exportTarget},
            onSelectionChanged: (value) => selectExportTarget(value.first),
          ),
          const SizedBox(height: 8),
          Text(
            'Target: ${policy.maxWidth}×${policy.maxHeight} · ${policy.videoBitrateKbps} kbps video',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (estimate != null && result == null) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.insights_rounded),
                title: Text('Estimated output: ${mb(estimate.bytes)}'),
                subtitle: Text(
                  'About ${(estimate.reductionRatio * 100).round()}% smaller before encoding',
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (result != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${mb(source?.sizeBytes ?? sample.sizeBytes)} → ${mb(result.sizeBytes)} · ${((session.reductionRatio ?? 0) * 100).round()}% smaller',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: simulateExport,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: Text('Export for ${targetLabel(exportTarget)}'),
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
