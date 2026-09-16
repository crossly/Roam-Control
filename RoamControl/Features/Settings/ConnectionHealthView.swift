import SwiftUI
import UIKit

struct ConnectionHealthView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var diagnostics = ConnectionDiagnosticsCoordinator()
    @State private var isShowingDeviceSetup = false
    @State private var didCopyDiagnostics = false

    var body: some View {
        List {
            Section("Connection Health") {
                healthRow(
                    title: "Connection Mode",
                    value: appModel.connectionConfiguration.mode.title,
                    symbol: appModel.connectionConfiguration.mode.systemImage,
                    color: .secondary
                )

                healthRow(
                    title: appModel.connectionConfiguration.mode == .localDevVPN
                        ? "LocalDevVPN"
                        : "Remote Endpoint",
                    value: connectionValue,
                    symbol: connectionSymbol,
                    color: connectionColor
                )

                if appModel.connectionConfiguration.mode == .remoteEndpoint {
                    healthRow(
                        title: "Endpoint",
                        value: appModel.connectionConfiguration.remoteEndpointDescription,
                        symbol: "network",
                        color: .secondary
                    )
                }

                healthRow(
                    title: "Pairing",
                    value: pairingValue,
                    symbol: pairingSymbol,
                    color: pairingColor
                )

                healthRow(
                    title: "Location Session",
                    value: sessionValue,
                    symbol: sessionSymbol,
                    color: sessionColor
                )

                healthRow(
                    title: "Background Session",
                    value: backgroundSessionValue,
                    symbol: backgroundSessionSymbol,
                    color: backgroundSessionColor
                )

                healthRow(
                    title: "Connection Stage",
                    value: appModel.deviceSession.connectionStage.title,
                    symbol: "point.3.connected.trianglepath.dotted",
                    color: sessionColor
                )

                if let endpointSource = appModel.deviceSession.endpointSource {
                    healthRow(
                        title: "Device Address",
                        value: endpointSource.title,
                        symbol: "network",
                        color: .secondary
                    )
                }

                if case .active = appModel.deviceSession.phase,
                   !appModel.deviceSession.backgroundKeepAlive.started {
                    Label(
                        "The current simulation can still work in the foreground, but background continuity is unavailable. Check Location access for Roam Control in Settings.",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                    .accessibilityElement(children: .combine)
                }
            }

            Section("Restoration") {
                Text(appModel.deviceSession.restorationStatus)
                Text("An inactive session means Roam Control's worker has ended. Other apps may need time to acquire a fresh real location.")
                    .foregroundStyle(.secondary)
            }

            Section("Current Location") {
                LabeledContent("Place", value: activeTarget?.name ?? "None")
                LabeledContent("Coordinates", value: coordinatesValue)

                if let activeTarget, !activeTarget.subtitle.isEmpty {
                    LabeledContent("Area", value: activeTarget.subtitle)
                }
            }

            Section {
                Button {
                    Task { await runConnectionCheck() }
                } label: {
                    HStack {
                        Label("Run Connection Check", systemImage: "stethoscope")
                        Spacer()
                        if diagnostics.state == .running {
                            ProgressView()
                        }
                    }
                }
                .disabled(diagnostics.state == .running)

                if let resultMessage {
                    Label(resultMessage, systemImage: resultSymbol)
                        .font(.subheadline)
                        .foregroundStyle(resultColor)
                }

                if let lastFailureMessage = appModel.deviceSession.lastFailureMessage {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Last session error", systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.orange)
                        Text(lastFailureMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(appModel.connectionConfiguration.mode == .localDevVPN
                            ? "Check LocalDevVPN, then run the connection check or try starting the location again."
                            : "Check the configured remote endpoint, then try starting the location again.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }

                if let lastChecked = diagnostics.lastChecked {
                    LabeledContent(
                        "Last checked",
                        value: lastChecked.formatted(date: .omitted, time: .shortened)
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            } header: {
                Text("Connection Check")
            } footer: {
                Text(appModel.connectionConfiguration.mode == .localDevVPN
                    ? "This checks the saved pairing record and whether the paired iPhone is visible through LocalDevVPN. It never starts, changes, or stops your location."
                    : "This checks whether the configured remote endpoint is reachable. It never starts, changes, or stops your location.")
            }

            Section {
                Button {
                    UIPasteboard.general.string = diagnosticsText
                    didCopyDiagnostics = true
                } label: {
                    Label(
                        didCopyDiagnostics ? "Diagnostics Copied" : "Copy Diagnostics",
                        systemImage: didCopyDiagnostics ? "checkmark" : "doc.on.doc"
                    )
                }
                .foregroundStyle(didCopyDiagnostics ? .green : .primary)
            } header: {
                Text("Support")
            } footer: {
                Text("Copies a status-only report you can paste into a bug report. It never includes locations, searches, pairing records, PINs, device names or error text.")
            }

            Section("Other VPNs") {
                if appModel.connectionConfiguration.mode == .localDevVPN {
                    Text("Another VPN may affect local device connections. If it is appropriate for your network, compare a test with that VPN paused. Keep LocalDevVPN enabled when starting a location session.")
                } else {
                    Text("Remote Endpoint mode does not open or require LocalDevVPN. Another VPN may still affect whether the configured endpoint is reachable.")
                }
                Text("Roam Control has not detected another VPN. This is a troubleshooting check, not a diagnosis; an iOS scheduler rejection happens before the pairing connection starts.")
                    .foregroundStyle(.secondary)
            }

            Section("Help") {
                NavigationLink {
                    ConnectionConfigurationView()
                        .environment(appModel)
                } label: {
                    Label("Connection Mode", systemImage: appModel.connectionConfiguration.mode.systemImage)
                }

                Button {
                    isShowingDeviceSetup = true
                } label: {
                    Label("Pairing & Connection", systemImage: "iphone.and.arrow.forward")
                }
                .foregroundStyle(.primary)

                if appModel.connectionConfiguration.mode == .localDevVPN {
                    Link(destination: appModel.localDevVPNInstallURL) {
                        Label("Open LocalDevVPN in App Store", systemImage: "arrow.up.right.square")
                    }
                }
            }
        }
        .navigationTitle("Connection Health")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            diagnostics.cancel()
        }
        .sheet(isPresented: $isShowingDeviceSetup) {
            PairingSetupView()
                .environment(appModel)
        }
    }

    private var activeTarget: LocationTarget? {
        if case .active(let target) = appModel.deviceSession.phase {
            return target
        }
        return nil
    }

    private var coordinatesValue: String {
        guard let activeTarget else { return "None" }
        return String(format: "%.5f, %.5f", activeTarget.latitude, activeTarget.longitude)
    }

    private var pairingValue: String {
        switch appModel.pairingStatus {
        case .checking: "Checking"
        case .importing: "Importing"
        case .notPaired: "Not paired"
        case .paired: "Ready"
        case .failed: "Problem"
        }
    }

    private var pairingSymbol: String {
        switch appModel.pairingStatus {
        case .checking, .importing: "arrow.triangle.2.circlepath"
        case .notPaired: "exclamationmark.circle"
        case .paired: "checkmark.circle.fill"
        case .failed: "xmark.circle.fill"
        }
    }

    private var pairingColor: Color {
        switch appModel.pairingStatus {
        case .checking, .importing: .blue
        case .notPaired: .orange
        case .paired: .green
        case .failed: .red
        }
    }

    private var connectionValue: String {
        switch diagnostics.state {
        case .notRun:
            if case .active = appModel.deviceSession.phase { return "Connected" }
            return "Not checked"
        case .running: return "Checking"
        case .passed: return "Reachable"
        case .failed: return "Not reachable"
        }
    }

    private var connectionSymbol: String {
        switch diagnostics.state {
        case .notRun:
            if case .active = appModel.deviceSession.phase { return "checkmark.circle.fill" }
            return "questionmark.circle"
        case .running: return "arrow.triangle.2.circlepath"
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }

    private var connectionColor: Color {
        switch diagnostics.state {
        case .notRun:
            if case .active = appModel.deviceSession.phase { return .green }
            return .secondary
        case .running: return .blue
        case .passed: return .green
        case .failed: return .red
        }
    }

    private var sessionValue: String {
        switch appModel.deviceSession.phase {
        case .idle: "Inactive"
        case .openingLocalDevVPN: "Opening LocalDevVPN"
        case .discovering: "Finding this iPhone"
        case .connecting: "Connecting"
        case .active: "Active"
        case .stopping: "Stopping"
        case .failed: "Failed"
        }
    }

    private var sessionSymbol: String {
        switch appModel.deviceSession.phase {
        case .idle: "pause.circle"
        case .openingLocalDevVPN, .discovering, .connecting: "arrow.triangle.2.circlepath"
        case .active: "location.circle.fill"
        case .stopping: "stop.circle"
        case .failed: "exclamationmark.triangle.fill"
        }
    }

    private var sessionColor: Color {
        switch appModel.deviceSession.phase {
        case .idle: .secondary
        case .openingLocalDevVPN, .discovering, .connecting, .stopping: .blue
        case .active: .green
        case .failed: .red
        }
    }

    private var backgroundSessionValue: String {
        appModel.deviceSession.backgroundKeepAlive.status.title
    }

    private var backgroundSessionSymbol: String {
        switch appModel.deviceSession.backgroundKeepAlive.status {
        case .receivingUpdates: "location.circle.fill"
        case .awaitingAuthorization, .starting: "arrow.triangle.2.circlepath"
        case .denied, .restricted, .servicesDisabled, .missingBackgroundMode, .failed:
            "exclamationmark.triangle.fill"
        case .locationUnavailable: "location.slash.circle"
        case .idle, .stopped: "pause.circle"
        }
    }

    private var backgroundSessionColor: Color {
        switch appModel.deviceSession.backgroundKeepAlive.status {
        case .receivingUpdates: .green
        case .awaitingAuthorization, .starting: .blue
        case .denied, .restricted, .servicesDisabled, .missingBackgroundMode, .failed: .orange
        case .locationUnavailable: .orange
        case .idle, .stopped: .secondary
        }
    }

    private var resultMessage: String? {
        switch diagnostics.state {
        case .notRun, .running: nil
        case .passed(let message), .failed(let message): message
        }
    }

    private var resultSymbol: String {
        switch diagnostics.state {
        case .passed: "checkmark.circle.fill"
        case .failed: "exclamationmark.triangle.fill"
        case .notRun, .running: "circle"
        }
    }

    private var resultColor: Color {
        switch diagnostics.state {
        case .passed: .green
        case .failed: .red
        case .notRun, .running: .secondary
        }
    }

    private func healthRow(
        title: String,
        value: String,
        symbol: String,
        color: Color
    ) -> some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: symbol)
                        .foregroundStyle(color)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                        Text(value)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Image(systemName: symbol)
                        .foregroundStyle(color)
                        .frame(width: 22)
                    Text(title)
                    Spacer()
                    Text(value)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value)")
    }

    @MainActor
    private func runConnectionCheck() async {
        do {
            let pairingRecord = try await appModel.pairingService.pairingRecordData()
            diagnostics.run(
                pairingRecord: pairingRecord,
                sessionPhase: appModel.deviceSession.phase,
                configuration: appModel.connectionConfiguration
            )
        } catch {
            diagnostics.run(
                pairingRecord: nil,
                sessionPhase: appModel.deviceSession.phase,
                configuration: appModel.connectionConfiguration
            )
        }
    }

    private var diagnosticsText: String {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        let runtimeBundleIdentifier = Bundle.main.bundleIdentifier ?? "Unknown"
        let permittedBackgroundTasks = (
            Bundle.main.object(forInfoDictionaryKey: "BGTaskSchedulerPermittedIdentifiers") as? [String]
        )?.joined(separator: ", ") ?? "None"
        let checked = diagnostics.lastChecked?.formatted(date: .numeric, time: .standard) ?? "Not run"

        return """
        Roam Control Diagnostics
        Generated: \(Date().formatted(date: .numeric, time: .standard))
        App: \(appVersion) (\(build))
        iOS: \(UIDevice.current.systemVersion)
        Runtime bundle identifier: \(runtimeBundleIdentifier)
        Runtime permitted background tasks: \(permittedBackgroundTasks)
        Pairing: \(pairingValue)
        Last pairing failure stage (this launch): \(appModel.onDevicePairing.lastFailureStage?.rawValue ?? "None")
        Pairing scheduler reason (this launch): \(appModel.onDevicePairing.schedulerFailureReason?.rawValue ?? "None")
        Pairing task configuration: \(appModel.onDevicePairing.taskConfigurationStatus.rawValue)
        Pairing task registration: \(appModel.onDevicePairing.taskRegistrationStatus.rawValue)
        Connection mode: \(appModel.connectionConfiguration.mode.title)
        Remote endpoint: \(appModel.connectionConfiguration.remoteEndpointDescription)
        Connection status: \(connectionValue)
        Session: \(sessionValue)
        Connection stage: \(appModel.deviceSession.connectionStage.title)
        Endpoint source: \(appModel.deviceSession.endpointSource?.title ?? "None")
        Last session issue stage (this launch): \(appModel.deviceSession.lastFailureStage?.rawValue ?? "None")
        Last session issue disposition: \(appModel.deviceSession.lastFailureDisposition?.rawValue ?? "None")
        Session scheduler reason (this launch): \(appModel.deviceSession.schedulerFailureReason?.rawValue ?? "None")
        Location task configuration: \(appModel.deviceSession.taskConfigurationStatus.rawValue)
        Location task registration: \(appModel.deviceSession.taskRegistrationStatus.rawValue)
        Location scheduler mode: Registration observation only (no task submitted)
        Background keep-alive: coreLocation
        Background keep-alive status: \(appModel.deviceSession.backgroundKeepAlive.status.rawValue)
        Background keep-alive started: \(appModel.deviceSession.backgroundKeepAlive.started)
        Location BG scheduler available: \(appModel.deviceSession.backgroundTelemetry.schedulerAvailable)
        Restoration: \(appModel.deviceSession.restorationStatus)
        Last connection check: \(checked)
        Connection check result: \(diagnosticResultStatus)
        Appearance: \(appModel.appearance.title)
        Map style: \(appModel.mapDisplayStyle.title)
        Location data: Not included
        """
    }

    private var diagnosticResultStatus: String {
        switch diagnostics.state {
        case .notRun: "Not run"
        case .running: "Running"
        case .passed: "Passed"
        case .failed: "Failed"
        }
    }
}

#Preview {
    NavigationStack {
        ConnectionHealthView()
            .environment(AppModel())
    }
}
