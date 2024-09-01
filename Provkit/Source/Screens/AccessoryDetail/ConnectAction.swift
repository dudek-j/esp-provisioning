import SwiftUI

struct ConnectAction: View {
    @Binding var loading: Bool

    let accessory: any Accessory
    let connect: () -> Void

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

}
