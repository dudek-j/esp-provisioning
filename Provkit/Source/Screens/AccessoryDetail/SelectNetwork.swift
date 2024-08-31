import SwiftUI

struct SelectNetwork: View {
    @State var networks: [any WifiNetwork]?

    let displayName: String
    let refresh: () async throws -> [any WifiNetwork]

    init(
        displayName: String,
        refresh: @escaping () async throws -> [any WifiNetwork]
    ) {
        self.displayName = displayName
        self.refresh = refresh
    }

    var body: some View {
        List(
            (networks ?? [])
                .sorted(using: KeyPathComparator(\.rssi))
                .reversed(),
            id: \.id ,
            rowContent: NetworkRow
        )
            .navigationTitle("Networks")
            .overlay(content: NoContent)
            .task(refreshNetworks)
            .refreshable(action: refreshNetworks)
    }

    @Sendable
    private func refreshNetworks() async {
        do {
            networks = try await refresh()
        } catch {
            networks = []
        }
    }
    private func NetworkRow(_ network: any WifiNetwork) -> some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(
                    systemName: "cellularbars",
                    variableValue: network.styling.percentage
                ).foregroundStyle(network.styling.color)

                VStack(alignment: .leading) {
                    Text(network.ssid)
                }
            }
        }.foregroundStyle(.foreground)
    }

    private func NoContent() -> some View {
        Group {
            if let networks, networks.isEmpty {
                ContentUnavailableView(
                    "\(displayName) could not find any networks",
                    systemImage: "wifi.slash",
                    description: Text("Pull to refresh")
                )
            }

            if networks == nil{
                ContentUnavailableView(label: {
                    ProgressView().controlSize(.regular)
                }, description: {
                    Text("\(displayName) is looking for networks")
                })
            }
        }
    }
}

#Preview {
    NavigationStack {
        SelectNetwork(
            displayName: "Sonos vinyl",
            refresh: { [
                PreviewNetwork(rssi: -40),
                PreviewNetwork(rssi: -52),
                PreviewNetwork(rssi: -62),
                PreviewNetwork(rssi: -80),
            ]
        })

    }
}
