import SwiftUI
import ESPProvision
import AccessorySetupKit

struct AccessoryDetail: View {
    @Environment(\.dismiss) var dismiss

    let connection: Connection
    let accessory: any Accessory

    @State var step: Step = .connect
    @State var loading = false
    @State var alert: AlertContent?

    init(accessory: any Accessory) {
        self.connection = Connection(accessory)
        self.accessory = accessory
    }

    var body: some View {
        CurrentStep()
            .toolbar(content: Toolbar)
            .interactiveDismissDisabled()
            .alert(item: $alert) { $0.view }
    }

    @ViewBuilder
    private func CurrentStep() -> some View {
        switch step {
        case .connect:
            ConnectAction(
                loading: $loading,
                accessory: accessory,
                connect: connect
            )
        case .selectWifi(let provisioning):
            SelectNetwork(
                displayName: accessory.displayName,
                refresh: provisioning.wifiList,
                onCredentials: {
                    setStep(
                        step: .provision(
                            provisioning: provisioning,
                            ssid: $0,
                            password: $1
                        )
                    )
                }
            )
        case .provision(_, let ssid, let password):
            Text("\(ssid)\n\(password)")
        }
    }

    private func setStep(step: Step) {
        withAnimation {
            self.step = step
        }

    }

    private func connect() {
        Task {
            loading = true
            do {
                let device = try await connection.establish()
                setStep(step: .selectWifi(provisioning: Provisioning(device)))
            } catch {
                alert = "DBG: \(error)"
            }
            loading = false
        }
    }

    private func Toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .disabled(loading)
        }
    }

    enum Step {
        case connect
        case selectWifi(provisioning: Provisioning)
        case provision(provisioning: Provisioning, ssid: SSID, password: Password)
    }
}


#Preview {
    NavigationStack {
        AccessoryDetail(
            accessory: PreviewAccessory(
                displayName: "Sonos vinyl",
                authorised: true
            )
        )
    }
}
