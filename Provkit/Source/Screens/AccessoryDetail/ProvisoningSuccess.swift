import SwiftUI

struct ProvisioningSuccess: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ActionView(
            image: "checkmark.circle.fill",
            imageColor: .green,
            title: "Network Provisioned",
            message: "Your device is now ready to use",
            button: { PrimaryButton(title: "Done", action: { dismiss() }) }
        )
    }
}

#Preview {
    NavigationStack {
        ProvisioningSuccess()
    }
}
