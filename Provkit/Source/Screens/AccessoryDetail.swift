import SwiftUI
import ESPProvision
import AccessorySetupKit

struct AccessoryDetail<Item: Accessory>: View {
    @Environment(\.dismiss) var dismiss

    let provisioning: Provisioning
    let accessory: Item

    @State var loading = false
    @State var alert: AlertContent?

    init(accessory: Item) {
        self.provisioning = Provisioning(accessory)
        self.accessory = accessory
    }

    var body: some View {
        ActionView(
            image: Image(systemName: "wifi"),
            title: accessory.displayName,
            message: "Make sure device is nearby before attempting to provision",
            action: {
                Button(
                    action: connect,
                    label: { ButtonLabel(title: "Connect", loading: $loading) }
                ).disabled(loading || !accessory.authorised)
            }
        )
        .toolbar(content: ToolbarContent)
        .interactiveDismissDisabled()
        .alert(item: $alert) { $0.view }
    }

    private func ToolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .disabled(loading)
        }
    }

    private func connect() {
        Task {
            loading = true
            do {
                try await provisioning.connect()
                let wifi = try await provisioning.wifiList()
                alert = "Success \(wifi.map(\..ssid))"
            } catch {
                alert = "DBG: \(error)"
            }
            loading = false
        }
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
