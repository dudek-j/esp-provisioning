import SwiftUI

struct AccessoryList<A: Accessory>: View {
    @State var selected: A?
    var accessories: [A]

    var body: some View {
        NavigationStack {
            List(accessories, id: \.id ,rowContent: AccessoryItem)
                .navigationTitle("Accessories")
                .sheet(item: $selected, content: AccessorySheet)
        }
    }

    private func AccessoryItem(_ accessory: A) -> some View {
        Button(action: { selected = accessory }) {
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
        }.foregroundStyle(.foreground)
    }

    private func AccessorySheet(_ accessory: A) -> some View {
        NavigationStack {
            AccessoryDetail(accessory: accessory)
        }.interactiveDismissDisabled()
    }
}

 #Preview {
    AccessoryList(accessories: [
        PreviewAccessory(displayName: "Sonos vinyl", authorised: true),
        PreviewAccessory(displayName: "Bedside lamp", authorised: false),
    ])
}
