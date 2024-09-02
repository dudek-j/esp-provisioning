import SwiftUI

struct ConnectAction: View {
    @Binding var loading: Bool

    let accessory: any Accessory
    let connect: () -> Void

    var body: some View {
        ActionView(
            image: "wifi",
            title: accessory.displayName,
            message: "Make sure device is nearby before attempting to provision",
            button: {
                PrimaryButton(
                    title: "Connect",
                    action: connect,
                    loading: loading,
                    disabled: loading || !accessory.authorised
                )
            }
        )
    }

}
