import SwiftUI

struct DiscoverAccessories: View {
    var discover: () -> Void

    var body: some View {
        ActionView(
            image:  "wifi.square",
            title: "No WiFi-accessory",
            message: "Make sure your accessory is nearby and in provisioning mode",
            action: {
                Button(
                    action: discover,
                    label: { ButtonLabel(title: "Discover") }
                )
            }
        )
    }
}

#Preview {
    DiscoverAccessories(discover: {})
}
