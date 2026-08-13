# Video Compress — Validation Experiment

## Problem
Users need to shrink large videos quickly for messaging, upload limits, storage pressure, and slower connections without learning encoding settings.

## Product wedge
One screen: pick a video, choose a target outcome (Small / Balanced / High quality), see estimated output size, compress, share.

## Monetization hypothesis
- Free: limited daily exports with a rewarded-ad option for additional exports.
- Premium: no ads, batch compression, custom target size, higher-resolution presets, background queue.
- Subscription should not be introduced until repeat-use data proves recurring value; one-time Pro is the safer first paid test.

## Organic / ASO hypothesis
Primary intent clusters: `video compressor`, `compress video`, `reduce video size`, `video size reducer`, `compress video for whatsapp`, and localized equivalents. Store creative should demonstrate a visible before/after file-size result rather than generic editing UI.

## MVP metrics
Track: install -> media permission -> video selected -> compression started -> compression completed -> share/export -> second compression. Measure activation, completion rate, time-to-first-export, D1/D7 reuse, rewarded-ad acceptance, and Pro intent.

## Go / kill gates
Do not scale acquisition until compression completion is reliable. Kill or radically reposition if, after a meaningful sample, activation is weak, successful users rarely perform a second compression, or organic installs fail to appear despite indexed store pages. Keep pricing experiments separate from core compression-quality experiments.

## Technical constraints
Compression must happen on-device for the MVP where feasible; avoid uploading private user videos to a server. Preserve originals by default, expose predicted output size before execution, and never claim lossless compression when transcoding.
