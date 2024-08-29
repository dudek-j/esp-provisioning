import SwiftUI

struct AccessoryList<A: Accessory>: View {
    var accessories: [A]

    var body: some View {
        NavigationStack {
            List(accessories, id: \.id ,rowContent: AccessoryItem)
                .navigationDestination(for: A.self, destination: AccessoryDetail.init)
                .navigationTitle("Accessories")
        }
    }

    private func AccessoryItem(_ accessory: A) -> some View {
        NavigationLink(value: accessory) {
            HStack(spacing: 16) {
                Circle()
                    .foregroundStyle(accessory.authorised ? .green : .red)
                    .frame(height: 10)
                VStack(alignment: .leading) {
                    Text(accessory.displayName)
                    Text(accessory.detailDescription)
                        .font(.caption)
                }
            }
        }.disabled(!accessory.authorised)
    }
}

 #Preview {
    AccessoryList(accessories: [
        PreviewAccessory(displayName: "Sonos vinyl", authorised: true),
        PreviewAccessory(displayName: "Bedside lamp", authorised: false),
    ])
}
