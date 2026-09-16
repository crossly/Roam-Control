import Network
import SwiftUI

struct ConnectionConfigurationView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    @State private var draftMode: DeviceConnectionMode = .localDevVPN
    @State private var draftRemoteHost = ConnectionConfiguration.defaultRemoteHost
    @State private var draftRemotePort = String(ConnectionConfiguration.defaultRemotePort)
    @State private var validationMessage: String?

    var body: some View {
        Form {
            Section {
                Picker("Mode", selection: $draftMode) {
                    ForEach(DeviceConnectionMode.allCases, id: \.self) { mode in
                        Label(mode.title, systemImage: mode.systemImage)
                            .tag(mode)
                    }
                }
                .pickerStyle(.inline)

                Text(draftMode.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } header: {
                Text("Connection Mode")
            } footer: {
                Text("LocalDevVPN keeps the original on-device path. Remote Endpoint uses the configured router hairpin endpoint and does not open LocalDevVPN.")
            }

            if draftMode == .remoteEndpoint {
                Section {
                    TextField("IP address", text: $draftRemoteHost)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)

                    TextField("Port", text: $draftRemotePort)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Remote Endpoint")
                } footer: {
                    Text("Default: 192.168.31.1:49152. The endpoint must be reachable from this iPhone and forward the RPPairing TCP port range back to this device.")
                }
            }

            Section {
                Button("Save Connection Settings") {
                    saveAndDismiss()
                }
            }
        }
        .navigationTitle("Connection Mode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    saveAndDismiss()
                }
            }
        }
        .onAppear {
            loadDraft()
        }
        .alert("Invalid Connection Settings", isPresented: isShowingValidationAlert) {
            Button("OK", role: .cancel) {
                validationMessage = nil
            }
        } message: {
            Text(validationMessage ?? "Please check the connection settings.")
        }
    }

    private var isShowingValidationAlert: Binding<Bool> {
        Binding(
            get: { validationMessage != nil },
            set: { if !$0 { validationMessage = nil } }
        )
    }

    private func loadDraft() {
        let configuration = appModel.connectionConfiguration
        draftMode = configuration.mode
        draftRemoteHost = configuration.remoteHost
        draftRemotePort = String(configuration.remotePort)
    }

    private func saveAndDismiss() {
        let configuration = appModel.connectionConfiguration

        if draftMode == .localDevVPN {
            configuration.apply(
                mode: .localDevVPN,
                remoteHost: configuration.remoteHost,
                remotePort: configuration.remotePort
            )
            dismiss()
            return
        }

        guard let port = UInt16(draftRemotePort.trimmingCharacters(in: .whitespacesAndNewlines)),
              port > 0 else {
            validationMessage = "Port must be a number between 1 and 65535."
            return
        }

        let host = draftRemoteHost.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !host.isEmpty else {
            validationMessage = "Remote endpoint host cannot be empty."
            return
        }

        guard IPv4Address(host) != nil || IPv6Address(host) != nil else {
            validationMessage = "Remote endpoint must be an IPv4 or IPv6 address."
            return
        }

        configuration.apply(
            mode: .remoteEndpoint,
            remoteHost: host,
            remotePort: port
        )
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ConnectionConfigurationView()
            .environment(AppModel())
    }
}
