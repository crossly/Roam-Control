# Roam Control releases

## 0.10.0 (Build 62 — Remote Endpoint preview)

- Created: 16 September 2026
- Package: `RoamControl-0.10.0-build62.ipa`
- Build: successful unsigned iPhoneOS Release archive for SideStore re-signing
- Requires: iOS 27.0 or later
- Xcode: 27.0 beta 6 (`27A5252f`)
- Distribution: prerelease artifact generated and published by GitHub Actions run `35075766453`
- SHA-256: `ea7e8d7ca9dad0c0272b5d3fe3b38487f11d837d71ef7e10333e09bafb9e3f93`
- Scope: adds selectable LocalDevVPN and Remote Endpoint transports, configurable router host/port, mode-aware connection diagnostics and native remote-session support.
- Validation: release-invariant checks, Rust native-bridge tests, both arm64 XCFramework slices, unsigned archive, IPA packaging, GitHub Release publication and bundle metadata checks passed. Physical-device Remote Endpoint validation remains pending.

## 0.9.2 (Build 56 — Beta 5)

- Created: 13 September 2026, 21:08 BST
- Package: `RoamControl-0.9.2-build56.ipa`
- Build: optimized unsigned Release for iPhone
- Requires: iOS 27.0 or later
- Xcode: 27.0 (`27A266a`)
- Distribution: unsigned IPA for SideStore re-signing
- Build timestamp: `2026-09-13T20:07:39Z`
- SHA-256: `ede639ef010e8ba1b4763e112f1fb272d9a56fdbb2267c4d09a504c7fec7cc5a`
- Validation: ZIP integrity, bundle identity and metadata checks passed. The final candidate was installed through SideStore and passed owner-device fixed-location, Stop & Restore and self-hosted telemetry consent-gating checks.
- Scope: carries forward bounded location-task registration validation and lifecycle hardening, adds fixed configuration/registration diagnostics and consent-gated self-hosted telemetry. It does not establish that all iOS `schedulerRegistration` failures are fixed.
- Packaging note: an earlier Build 56 package with a stale embedded build timestamp was rejected during validation and is not the release artifact. The SHA-256 above identifies the final candidate.


## 0.9.2 (Build 54 — private diagnostic)

- Distribution: private diagnostic build only; not published as a public release.
- Scope: location continued-processing task registration validation and fixed copied-diagnostic fields only.
- History: the Build 54 source changes were not committed and are not present in the retained Git history. Build 55 reconstructs the narrowly scoped validation rather than treating Build 54 as a source baseline.
- Validation: external validation was limited. Build 54 does not establish that `schedulerRegistration` failures were fixed.

## 0.9.2 (Build 53)

- Created: 12 September 2026
- Package: `RoamControl-0.9.2-Beta3-build53.ipa`
- Build: optimized unsigned Release, stripped arm64 iPhone executable
- Requires: iOS 27.0 or later
- Distribution: unsigned IPA (for SideStore re-signing)
- SHA-256: `5222a17a68fe88ad059bda8d91569ead39f65bc5f85c5132bddff0dbec3f187b`
- Change: stability and reliability update focused on pairing cancellation and scheduler handling, bounded LocalDevVPN recovery, clearer session diagnostics, more reliable Stop & Restore acknowledgement and privacy-preserving recovery/failure telemetry.

## 0.9.1 (Build 47)

- Created: 10 September 2026, 18:06 BST
- Package: `RoamControl-0.9.1-build47.ipa`
- Build: optimized unsigned Release, stripped arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 beta (`27A5252f`)
- Distribution: unsigned IPA (for SideStore re-signing)
- SHA-256: `9d72c2e14a5b5b5c83f516ac4b7f1fdde14bbb5d806c0083f8ca7c2f3d44d9b1`
- Change: incorporates the first wave of public-beta feedback: clearer stop-and-restore progress, improved interrupted-session recovery, compact background task presentation, richer place search and reorderable favourites. Adds Copy Diagnostics, GitHub feedback forms, manual update checks and privacy-preserving telemetry for handled failures.

## 0.9.0 (Build 29)

- Created: 4 September 2026, 15:36 BST
- Package: `RoamControl-0.9.0-build29.ipa`
- Build: optimized Release, stripped arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 beta (`27A5252f`)
- Distribution: unsigned IPA (for SideStore re-signing)
- SHA-256: `af48336dd735286783b6d7269776ca95f5f34b97b81f9ed6a1f8679768220f37`
- Change: hardens anonymous statistics for public beta. New installs now start with sharing off, saved choices are preserved, app foreground activity is counted without a per-launch session ID, participation is confirmed only after successful delivery, and failed location updates are not counted. The privacy disclosure now includes approximate event time and retention, the app contains an Apple privacy manifest, and the live TelemetryDeck destination is held outside the public project configuration.

## 0.9.0 (Build 28)

- Created: 4 September 2026, 14:48 BST
- Package: `RoamControl-0.9.0-build28.ipa`
- Build: optimized Release, stripped arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 beta (`27A5252f`)
- Distribution: unsigned IPA (for SideStore re-signing)
- SHA-256: `21205149bf4b54df54de5387c97f78957c50fc6e0e6f0933b856a1778494d535`
- Change: adds clearly disclosed optional anonymous usage statistics. New users see the enabled switch before setup completes; existing installations remain disabled until explicitly enabled. The direct TelemetryDeck client sends only fixed activity events, app version/build and a hashed random installation identifier—never locations, searches, routes, saved places, pairing material, personal details or diagnostics.

## 0.9.0 (Build 27)

- Created: 4 September 2026, 13:25 BST
- Package: `RoamControl-0.9.0-build27.ipa`
- Build: optimized Release, arm64 iPhone
- Requires: iOS 27.0 or later
- Xcode: 27.0 beta (`27A5252f`)
- Distribution: unsigned IPA (for SideStore re-signing)
- SHA-256: `44c7b69f280edaca58d77dd41b927bfca7003870cf85433d76ce5f7a94eada32`
- Change: permits both the Xcode bundle identifier and SideStore's team-suffixed bundle identifier for pairing and location background tasks. The build timestamp is now embedded so it remains accurate after SideStore re-signs the app.

## 0.9.0 (Build 26)

- Created: 4 September 2026, 13:18 BST
- Package: `RoamControl-0.9.0-build26.ipa`
- Build: optimized Release, arm64 iPhone
- Requires: iOS 27.0 or later
- Xcode: 27.0 beta (`27A5252f`)
- Distribution: unsigned IPA (for SideStore re-signing)
- SHA-256: `925a8a5cb62e8729a668880d76b6f1ea9327a4536f9260980cadd00d82389f57`
- Change: background-task identifiers now follow the installed IPA's permitted identifiers, allowing pairing and location sessions after SideStore renames and re-signs the app.

## 0.9.0 (Build 25)

- Created: 4 September 2026, 13:01 BST
- Package: `RoamControl-0.9.0-build25.ipa`
- Build: optimized Release, arm64 iPhone
- Requires: iOS 27.0 or later
- Xcode: 27.0 beta (`27A5252f`)
- Distribution: unsigned IPA (for SideStore re-signing)
- SHA-256: `3ef4b5808ea462bf7058232f99d4da157594aebcde7c2217f200d618ef985042`

The IPA passed ZIP integrity and payload-layout checks. Complete the device regression checklist after installing it through SideStore because SideStore's signing identity differs from an Xcode-installed build.
