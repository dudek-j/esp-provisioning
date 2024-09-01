import SwiftUI
import ESPProvision
import AccessorySetupKit

struct AccessoryDetail: View {
    @Environment(\.dismiss) var dismiss

    let provisioning: Provisioning
    let accessory: any Accessory

    @State var step: Step = .connect
    @State var loading = false
    @State var alert: AlertContent?

    init(accessory: any Accessory) {
        self.provisioning = Provisioning(accessory)
        self.accessory = accessory
    }

    var body: some View {
        CurrentStep()
            .toolbar(content: Toolbar)
            .interactiveDismissDisabled()
            .alert(item: $alert) { $0.view }
    }

    private func CurrentStep() -> some View {
        Group {
            switch step {
            case .connect:
                ConnectAction(
                    loading: $loading,
                    accessory: accessory,
                    connect: connect
                )
            case .selectWifi:
                SelectNetwork(
                    displayName: accessory.displayName,
                    refresh: provisioning.wifiList
                )
            }
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
                try await provisioning.connect()
                setStep(step: .selectWifi)
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
        case selectWifi
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
