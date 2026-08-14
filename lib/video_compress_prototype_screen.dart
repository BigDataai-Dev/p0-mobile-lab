import 'package:flutter/material.dart';
import 'experiment_analytics.dart';
import 'video_backend_capabilities.dart';
import 'video_compression_session.dart';
import 'video_compressor.dart';
import 'video_export_policy.dart';
import 'video_intake_policy.dart';
import 'video_picker_contract.dart';
import 'video_selection_controller.dart';
import 'video_selection_state.dart';
import 'video_size_estimator.dart';
import 'video_value_estimate.dart';
import 'video_workflow_gate.dart';
import 'video_workflow_status.dart';

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

  VideoValueEstimate? currentValueEstimate() {
    final source = session.source;
    final estimate = currentEstimate();
    if (source == null || estimate == null) return null;
    return VideoValueEstimate(
      originalBytes: source.sizeBytes,
      estimatedBytes: estimate.bytes,
    );
  }

  VideoSelectionState workflowSelectionState() {
    final decision = lastIntakeDecision;
    if (decision == null || session.source == null) {
      return const VideoSelectionState.idle();
    }
    final picked = PickedVideo(
      uri: sample.path,
      fileName: sample.path,
      sizeBytes: sample.sizeBytes,
      duration: Duration(milliseconds: sample.durationMs),
      mimeType: 'video/mp4',
    );
    return VideoSelectionState.fromResult(
      VideoSelectionResult(
        selection: VideoSelection.selected(picked),
        intakeDecision: decision,
      ),
    );
  }

  VideoWorkflowStatus workflowStatus(VideoWorkflowMode mode) {
    return VideoWorkflowStatus.from(
      mode: mode,
      selection: workflowSelectionState(),
      backend: prototypeVideoBackend,
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
    final value = VideoValueEstimate(
      originalBytes: source.sizeBytes,
      estimatedBytes: estimate.bytes,
    );
    analytics.track('compression_started', {
      'preset': session.preset.name,
      'input_size_bytes': source.sizeBytes,
      'estimated_output_bytes': estimate.bytes,
      'target': exportTarget.name,
      ...value.toAnalytics(),
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
      'target': exportTarget.name,
      ...value.toAnalytics(),
    });
  }

  void simulateExport() {
    final result = session.result;
    final source = session.source;
    if (result == null || source == null) return;
    final policy = VideoExportPolicy.forTarget(exportTarget);
    final value = VideoValueEstimate(
      originalBytes: source.sizeBytes,
      estimatedBytes: result.sizeBytes,
    );
    analytics.track('compressed_video_exported', {
      'preset': session.preset.name,
      'target': exportTarget.name,
      'output_size_bytes': result.sizeBytes,
      'max_width': policy.maxWidth,
      'max_height': policy.maxHeight,
      'video_bitrate_kbps': policy.videoBitrateKbps,
      ...value.toAnalytics(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved ${mb(value.savedBytes)} · export ready for ${exportTarget.name}',
        ),
      ),
    );
  }

  String mb(int bytes) => '${(bytes / 1000000).toStringAsFixed(1)} MB';

  String targetLabel(ExportTarget target) => switch (target) {
        ExportTarget.messaging => 'Messaging',
        ExportTarget.social => 'Social',
        ExportTarget.archive => 'Archive',
      };

  Widget readinessCard(BuildContext context, VideoWorkflowStatus status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.allowed
                      ? Icons.check_circle_outline_rounded
                      : Icons.construction_rounded,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (status.details.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final detail in status.details)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $detail'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = session.result;
    final source = session.source;
    final policy = VideoExportPolicy.forTarget(exportTarget);
    final estimate = currentEstimate();
    final value = currentValueEstimate();
    final prototypeStatus = workflowStatus(VideoWorkflowMode.prototype);
    final productionStatus = workflowStatus(VideoWorkflowMode.production);
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
          readinessCard(context, prototypeStatus),
          const SizedBox(height: 8),
          readinessCard(context, productionStatus),
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
          if (estimate != null && value != null && result == null) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.insights_rounded),
                title: Text(value.headline),
                subtitle: Text(
                  '${mb(source!.sizeBytes)} → ~${mb(estimate.bytes)} · save ~${mb(value.savedBytes)} (${value.savingsPercent}%)',
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (result != null && source != null)
            Builder(
              builder: (context) {
                final completedValue = VideoValueEstimate(
                  originalBytes: source.sizeBytes,
                  estimatedBytes: result.sizeBytes,
                );
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          completedValue.headline,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${mb(source.sizeBytes)} → ${mb(result.sizeBytes)} · saved ${mb(completedValue.savedBytes)} (${completedValue.savingsPercent}%)',
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
                );
              },
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
