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

## First experiment selection rule

Do not choose an app because it is easy to code. Choose an app where search intent, repeated use or shareability can plausibly create organic distribution.

## Repository strategy

`p0-mobile-lab` holds the shared core and experiments before validation. A winner graduates into its own repository and brand.
