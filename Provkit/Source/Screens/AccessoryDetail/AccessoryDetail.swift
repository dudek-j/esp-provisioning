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
            ConnectAction(loading: $loading, accessory: accessory, connect: connect)
        case .selectWifi(let provisioning):
            SelectNetwork(
                displayName: accessory.displayName,
                refresh: provisioning.wifiList,
                onCredentials: { credentials in
                    setStep(step: .provision(
                        send: { provisioning.send(credentials) },
                        tryAgain: { setStep(step: .selectWifi(provisioning)) }
                    ))
                }
            )
        case .provision(let sendCredentials, let tryAgain):
            ProvisioningProgress(
                loading: $loading,
                sendCredentials: sendCredentials,
                tryAgain: tryAgain,
                onSuccess: { setStep(step: .success) }
            )
        case .success:
            ProvisioningSuccess()
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
                setStep(step: .selectWifi(Provisioning(device)))
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
        case selectWifi(_ provisioning: Provisioning)
        case provision(send: SendCredentials, tryAgain: () -> Void)
        case success
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
