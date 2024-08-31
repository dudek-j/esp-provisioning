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
        ConnectAction(
            alert: $alert,
            loading: $loading,
            provisioning: provisioning,
            accessory: accessory
        )
        .toolbar(content: Toolbar)
        .interactiveDismissDisabled()
        .alert(item: $alert) { $0.view }
    }

    private func Toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .disabled(loading)
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
