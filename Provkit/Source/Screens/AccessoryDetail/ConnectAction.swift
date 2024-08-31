import SwiftUI

struct ConnectAction: View {
    @Binding var alert: AlertContent?
    @Binding var loading: Bool

    let provisioning: Provisioning
    let accessory: any Accessory
    let onConnect: () -> Void

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
    }

    private func connect() {
        Task {
            loading = true
            do {
                try await provisioning.connect()
                onConnect()
            } catch {
                alert = "DBG: \(error)"
            }
            loading = false
        }
    }
}
