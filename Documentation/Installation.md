# Installation

Roam Control is not distributed through the App Store or TestFlight. Public beta builds are supplied as unsigned IPA files for users to sign with their own Apple account.

## Requirements

- An iPhone running iOS 27 or newer.
- Developer Mode enabled under **Settings → Privacy & Security**.
- A valid RPPairing file. First-time on-device pairing may still use LocalDevVPN; Remote Endpoint mode requires importing an existing pairing file.
- [LocalDevVPN](https://apps.apple.com/app/localdevvpn/id6755608044) for LocalDevVPN mode, or a router endpoint reachable from the iPhone for Remote Endpoint mode.
- SideStore, or Xcode on a Mac with an Apple development team.

## Install with SideStore

1. Download the IPA attached to the matching GitHub Release. Do not download an IPA from an untrusted mirror.
2. In SideStore, tap **+** and choose the downloaded IPA.
3. Allow SideStore to sign and install Roam Control with your Apple account.
4. Open Roam Control and complete its introduction. Pair this iPhone through LocalDevVPN, or import an existing RPPairing file from Device Setup.
5. Open **Settings → Device → Connection Mode**. Use LocalDevVPN with its tunnel, or choose Remote Endpoint and keep LocalDevVPN off.

## Remote Endpoint mode

Remote Endpoint mode reaches the iPhone's RPPairing service through the router's TCP hairpin path. The default endpoint is `192.168.31.1:49152`; the router must forward the subsequent TCP high ports back to this iPhone. The pairing file stays on the iPhone and is never copied to the router.

Free Apple accounts normally require sideloaded apps to be refreshed within seven days and limit the number of simultaneously active apps/App IDs. These are Apple signing limits, not Roam Control subscriptions.

When updating, install the newer IPA over the existing copy. Deleting the app first also deletes its local settings and may require pairing again.

## Build with Xcode

1. Clone the repository and open `RoamControl.xcodeproj`.
2. Select the Roam Control target and choose your own team under **Signing & Capabilities**.
3. Select a connected iPhone and press **Run**.

The tracked build configuration has no Apple team or TelemetryDeck destination. Xcode may save your selected team locally. Do not commit signing material or `Configuration/Local.private.xcconfig`.

The simulator can test the interface but cannot complete the physical iPhone pairing handshake or start a real location session.

## Verify a release

Each GitHub Release publishes the IPA's SHA-256 checksum. On a Mac, calculate the checksum of the IPA you downloaded:

```sh
shasum -a 256 RoamControl-0.10.0-build62.ipa
```

Compare the result with the SHA-256 value shown on the matching GitHub Release before installing it.

See the [user guide](UserGuide.md) for pairing and everyday operation.
