# Build and Release Guide

This guide covers Roam Control's development builds and the planned IPA workflow.

## Current release identity

- Marketing version: `0.10.0`
- Current build: `62`
- Bundle identifier: `com.sean.roamcontrol`
- Minimum deployment target: iOS 27
- Supported device family: iPhone

The version and build are shown in **Settings** inside the app. The built date and time come from the timestamp embedded for that packaged build.

## Version and build rules

Roam Control uses two separate numbers:

- The **version** describes the public release. Increase it for each public beta or stable release; the first stable release will become `1.0.0`.
- The **build** identifies one exact install. Increase it once for every build installed on a test iPhone or packaged as an IPA.

Ordinary compile checks do not consume a build number. Build numbers must never move backwards for a later install or upload.

Both values are stored in the target build settings:

- `MARKETING_VERSION`
- `CURRENT_PROJECT_VERSION`

Keep the Debug and Release configurations identical.

## Build in Xcode

1. Open `RoamControl.xcodeproj`.
2. Select the **RoamControl** scheme.
3. Select the connected iPhone.
4. Open **Signing & Capabilities** and confirm the development team.
5. Press **Run**.

The simulator can validate most interface states, but it cannot perform the real RPPairing handshake or start a location session.

## Native pairing engine

The prebuilt `Frameworks/RoamPairingFFI.xcframework` should be committed with both arm64 iPhone and arm64 Apple Silicon simulator slices.

Only rebuild it after changing `Native/RoamPairingFFI`. The rebuild requires Rust targets for:

- `aarch64-apple-ios`
- `aarch64-apple-ios-sim`

Run `scripts/build-pairing-engine.sh` from the project directory. Confirm the app still builds for both a physical iPhone and the simulator afterwards.

## Connection-mode validation

The release checklist must cover both transports:

- LocalDevVPN mode: the original on-device tunnel, mDNS discovery and `10.7.0.1` fallback remain functional.
- Remote Endpoint mode: **Settings → Device → Connection Mode** selects `Remote Endpoint`; the default endpoint is `192.168.31.1:49152`; LocalDevVPN remains disconnected; Connection Health reports the configured endpoint as reachable; and a fixed-location session reaches LocationSimulation through the router hairpin path.

Remote Endpoint mode requires an existing valid RPPairing file. The router forwards encrypted TCP traffic only; never copy the pairing file into the router or the repository.

## Archive preparation

Before creating an archive:

1. Finish the regression checklist.
2. Increase `CURRENT_PROJECT_VERSION` for the archive.
3. Confirm the public version.
4. Use the Release configuration.
5. Confirm the app icon and display name.
6. Set and verify the build timestamp.
7. For a configured public build, set the self-hosted ingestion token and any TelemetryDeck identifiers in the ignored private configuration.
8. Confirm no live ingestion token is tracked or shown in the staged diff.
9. Confirm `RoamPairingFFI.xcframework` is embedded and signed.
10. Build once for a physical iPhone.

Then select **Any iOS Device (arm64)** and choose **Product → Archive**. Xcode opens Organizer after a successful archive.

## IPA and SideStore

Roam Control's SideStore IPA is built from an optimized, unsigned Release archive. SideStore applies the user's personal development certificate during installation. The native pairing engine is statically linked into the app binary, so it does not need a separate framework or extension.

For personal SideStore installation:

1. Use the verified IPA from `Releases`, or create a new one from a Release archive.
2. Move the IPA to Files or another location SideStore can access.
3. Open SideStore, choose the IPA and allow SideStore to sign/install it with the configured Apple ID.
4. Keep Developer Mode enabled.
5. Complete Roam Control's pairing on the installed copy if its signing identity gives it a new Keychain container.

SideStore re-signing and Apple's free-account limits can affect expiry, app identifiers and available entitlements. The final IPA must therefore be tested as a SideStore install rather than assuming an Xcode-installed build is equivalent. With a free Apple Account, SideStore normally refreshes the signed installation within Apple's seven-day development period.

Do not treat an Xcode Debug `.app` folder renamed to `.ipa` as a release package. Use the verified Release archive/package workflow.

## Privacy statistics configuration

Optional statistics are sent by Roam Control's narrow first-party client. A configured release sends in parallel to the maintainer-operated HTTPS endpoint and TelemetryDeck's Ingest API. Roam Control does not embed an analytics SDK and permits only the event names and fixed fields defined in `UsageAnalyticsService.swift`.

Three private build settings configure those destinations:

- `ROAMCONTROL_SELFHOSTED_TELEMETRY_TOKEN`
- `ROAMCONTROL_TELEMETRY_APP_ID`
- `ROAMCONTROL_TELEMETRY_NAMESPACE`

The self-hosted ingestion token is sensitive configuration and must never be committed, printed in release notes or included in a patch. The TelemetryDeck App ID and namespace are ingestion identifiers rather than account credentials, but they remain blank in tracked defaults. Copy `Configuration/Local.private.xcconfig.example` to the ignored `Configuration/Local.private.xcconfig` and set values only for a configured local or release build. The same private file can hold the local `DEVELOPMENT_TEAM`.

The self-hosted endpoint URL is public configuration in `RoamControl-Info.plist`; without its private token it sends nothing. TelemetryDeck requires both of its private values. If both destinations are configured, the same consent-gated fixed event is sent to each in parallel. If neither destination is fully configured, no request is made.

Before packaging a configured build, inspect the event structure, confirm the privacy disclosure still matches it, and run the privacy rows in the regression checklist. Never add coordinates, place text, searches, saved locations, routes, pairing material, device names, user-supplied text or diagnostic content to an event.

## Release records

For each distributed build, record:

- Version and build number.
- Date and time created.
- Xcode and iOS versions used.
- Signing method.
- Device used for testing.
- Regression checklist result.
- Known issues.

This makes a problem report traceable to the exact binary shown in Roam Control's Settings screen.
