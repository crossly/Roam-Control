# Roam Control 0.10.0 Preview — Build 62

Roam Control 0.10.0 Preview adds a selectable Remote Endpoint transport while preserving the existing LocalDevVPN path. The remote transport is intended for a router TCP hairpin path that sends the iPhone's RPPairing port and subsequent high TCP ports back to that same iPhone.

## Build information

- Package: `RoamControl-0.10.0-build62.ipa`
- Version: `0.10.0` Build `62`
- Minimum system: iOS 27.0
- Architecture: arm64
- Signing: unsigned; sign with SideStore or your own Apple development identity
- Bundle identifier: `com.sean.roamcontrol`

## Changes

- Added **Settings → Device → Connection Mode**.
- Preserved **LocalDevVPN** as the default mode and existing on-device discovery flow.
- Added **Remote Endpoint** with configurable IPv4/IPv6 address and TCP port.
- Default Remote Endpoint: `192.168.31.1:49152`.
- Remote Endpoint mode does not open or fall back to LocalDevVPN.
- Added mode-aware Connection Health, connection stages, endpoint source and copied diagnostics.
- Kept cryptographic RPPairing verification in the native bridge; Remote Endpoint skips only the volatile mDNS metadata pre-filter.
- Reset restores LocalDevVPN mode and the default remote endpoint.

## Requirements

1. Enable iOS Developer Mode.
2. Pair this iPhone through LocalDevVPN, or import a valid RPPairing file from Device Setup.
3. For Remote Endpoint mode, configure the router to hairpin the iPhone's TCP traffic for `192.168.31.1:49152` and subsequent high ports back to that iPhone.
4. Select **Remote Endpoint** under **Settings → Device → Connection Mode**.
5. Run **Connection Health** before starting a location session.

The pairing file remains in the iPhone Keychain. It is not uploaded to the router or to GitHub.

## Validation status

- The repository includes release-invariant checks for the version, mode defaults, endpoint wiring, diagnostics and native metadata-verification switch.
- The Rust native bridge and both arm64 XCFramework slices are rebuilt by the release workflow.
- A real iPhone still needs to validate Remote Endpoint fixed location, in-session updates, Stop & Restore, interrupted-session recovery and long-running background behavior. This release note does not claim those physical-device checks until they are performed.
- The final IPA SHA-256 and CI run details are recorded after the release workflow completes.
