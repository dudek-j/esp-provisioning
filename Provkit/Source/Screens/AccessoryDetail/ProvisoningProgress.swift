import SwiftUI

struct ProvisioningProgress: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            LargeImage(systemName: "rectangle.connected.to.line.below")
            ProgressIndicators()
            Spacer()
            TryAgain()
                .padding(.top, 36)
        }.padding(64)
    }

    private func ProgressIndicators() -> some View {
        VStack(alignment: .leading) {
            Label(
                title: { Text("Sending configuration")},
                icon: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                }
            )
            Label(
                title: { Text("Verifying connection")},
                icon: { ProgressView() }
            )
        }
    }

    private func TryAgain() -> some View {
        PrimaryButton(title: "Try again", action: {})
            .opacity(1)
    }
}

#Preview {
    NavigationStack {
        ProvisioningProgress()
    }
}
