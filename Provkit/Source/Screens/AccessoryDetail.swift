import SwiftUI
import ESPProvision
import AccessorySetupKit

struct AccessoryDetail<Item: Accessory>: View {
    let provisioning: Provisioning
    let accessory: Item

    @State var loading = false

    @State var showAlert = false
    @State var alert: String?

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
        ).alert(isPresented: $showAlert) {
            Alert(title: Text(alert ?? "Nothing here"))
        }
    }

    private func connect() {
        Task {
            loading = true
            do {
                let provisoning = Provisioning(accessory)
                try await provisoning.connect()
                let wifi = try await provisoning.wifiList()
                alert("Success \(wifi.map(\..ssid))")
            } catch {
                alert("DBG: \(error)")
            }
            loading = false
        }
    }

    private func alert(_ title: String) {
        alert = title
        showAlert = true

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
