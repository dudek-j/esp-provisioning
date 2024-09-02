import SwiftUI

struct DiscoverAccessories: View {
    var discover: () -> Void

    var body: some View {
        ActionView(
            image:  "wifi.square",
            title: "No WiFi-accessory",
            message: "Make sure your accessory is nearby and in provisioning mode",
            button: {
                PrimaryButton(title: "Discover", action: discover)
            }
        )
    }
}

#Preview {
    DiscoverAccessories(discover: {})
}
