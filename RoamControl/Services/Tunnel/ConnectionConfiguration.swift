import Foundation
import Observation

enum DeviceConnectionMode: String, CaseIterable, Codable, Hashable, Sendable {
    case localDevVPN
    case remoteEndpoint

    var title: String {
        switch self {
        case .localDevVPN:
            "LocalDevVPN"
        case .remoteEndpoint:
            "Remote Endpoint"
        }
    }

    var systemImage: String {
        switch self {
        case .localDevVPN:
            "lock.shield"
        case .remoteEndpoint:
            "network"
        }
    }

    var description: String {
        switch self {
        case .localDevVPN:
            "Use the on-device LocalDevVPN loopback tunnel."
        case .remoteEndpoint:
            "Connect through a configured router endpoint without LocalDevVPN."
        }
    }
}

@Observable
final class ConnectionConfiguration {
    static let defaultRemoteHost = "192.168.31.1"
    static let defaultRemotePort: UInt16 = 49152

    private enum Key {
        static let mode = "deviceConnectionMode"
        static let remoteHost = "deviceRemoteEndpointHost"
        static let remotePort = "deviceRemoteEndpointPort"
    }

    private let preferences: UserDefaults

    private(set) var mode: DeviceConnectionMode {
        didSet { preferences.set(mode.rawValue, forKey: Key.mode) }
    }

    private(set) var remoteHost: String {
        didSet { preferences.set(remoteHost, forKey: Key.remoteHost) }
    }

    private(set) var remotePort: UInt16 {
        didSet { preferences.set(Int(remotePort), forKey: Key.remotePort) }
    }

    init(preferences: UserDefaults = .standard) {
        self.preferences = preferences
        self.mode = DeviceConnectionMode(
            rawValue: preferences.string(forKey: Key.mode) ?? ""
        ) ?? .localDevVPN

        let storedHost = preferences.string(forKey: Key.remoteHost)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self.remoteHost = storedHost.isEmpty ? Self.defaultRemoteHost : storedHost

        let storedPort = preferences.integer(forKey: Key.remotePort)
        self.remotePort = storedPort > 0 && storedPort <= Int(UInt16.max)
            ? UInt16(storedPort)
            : Self.defaultRemotePort
    }

    var remoteEndpointDescription: String {
        remoteHost.contains(":") ? "[\(remoteHost)]:\(remotePort)" : "\(remoteHost):\(remotePort)"
    }

    func apply(
        mode: DeviceConnectionMode,
        remoteHost: String,
        remotePort: UInt16
    ) {
        let normalizedHost = remoteHost.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedHost.isEmpty, remotePort > 0 else { return }

        self.mode = mode
        self.remoteHost = normalizedHost
        self.remotePort = remotePort
    }

    func reset() {
        mode = .localDevVPN
        remoteHost = Self.defaultRemoteHost
        remotePort = Self.defaultRemotePort
    }
}
