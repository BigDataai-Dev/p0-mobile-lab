# P0 Mobile Lab

P0 Mobile Lab is the shared experimentation workspace for small consumer iOS/Android utilities.

The goal is not to accumulate random apps. The goal is to build a repeatable system that can test narrow mobile problems quickly, measure real demand, kill weak ideas and spin winning experiments into their own products.

## Operating model

Each experiment must define before implementation:

- one user problem;
- one primary acquisition hypothesis;
- one monetization hypothesis;
- one activation event;
- one retention signal;
- one kill threshold.

## Shared foundation

The lab will progressively centralize:

- Flutter application shell;
- experiment registry;
- analytics event contract;
- remote configuration;
- paywall/subscription abstraction;
- rewarded/interstitial ad abstraction;
- feature flags;
- localization;
- common privacy/consent surfaces;
- reusable onboarding and settings components.

Vendor SDKs are intentionally not wired in the first commit. The contracts come first so experiments do not become coupled to one analytics, ads or subscription provider.

## Current shortlist

### Photo Cleanup

Hypothesis: users want a fast, narrow flow for removing unwanted objects or distractions without opening a full photo editor. The natural activation event is a first successful export. Monetization should favor limited free edits, rewarded extra edits, credits or a light premium tier rather than blocking the first useful result.

Kill signal: generated cleanup quality is inconsistent enough that users fail to export or immediately abandon the result.

### Video Compress

Hypothesis: "make this video small enough to send/upload" is a concrete, measurable job that can be reduced to a one-screen workflow. The activation event is a compressed video successfully saved or shared. Ads, batch processing, pro presets and a no-ads purchase fit the job naturally.

Kill signal: weak repeat usage plus weak organic acquisition after a clean first-use experience.

### Ringtone Maker

Hypothesis: owned audio to phone-ready ringtone is easy to understand and comparatively cheap to build. Monetization should be light ads plus a one-time no-ads purchase, not an aggressive subscription.

Kill signal: platform installation friction dominates completion, reviews or support even after onboarding is simplified.

## Portfolio rule

Keep at most one utility in active build and one in validation. Shared infrastructure may advance continuously, but product feature work belongs to the currently selected hypothesis. A small profitable app may stay small; only strong retention or acquisition earns deeper investment.

## First experiment selection rule

Do not choose an app because it is easy to code. Choose an app where search intent, repeated use or shareability can plausibly create organic distribution.

## Repository strategy

`p0-mobile-lab` holds the shared core and experiments before validation. A winner graduates into its own repository and brand.
