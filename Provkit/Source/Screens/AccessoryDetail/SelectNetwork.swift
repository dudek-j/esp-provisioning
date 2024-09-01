import SwiftUI

typealias SSID = String
typealias Password = String

struct SelectNetwork: View {
    @State var networks: [any WifiNetwork]?
    @State var alert: AlertContent?

    @State var selectedSSID: String?
    @State var password: String = ""

    let displayName: String
    let refresh: () async throws -> [any WifiNetwork]
    let onCredentials: (SSID, Password) -> Void


    init(
        displayName: String,
        refresh: @escaping () async throws -> [any WifiNetwork],
        onCredentials: @escaping (SSID, Password) -> Void
    ) {
        self.displayName = displayName
        self.refresh = refresh
        self.onCredentials = onCredentials
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
            .alert(
                "Enter password for \n \(selectedSSID ?? "")",
                isPresented: .constant(selectedSSID != nil),
                actions: PasswordAlert
            )
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
        Button(action: {
            selectedSSID = network.ssid
        }) {
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

    @ViewBuilder
    private func NoContent() -> some View {
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

    @ViewBuilder
    private func PasswordAlert() -> some View {
        SecureField("Password", text: $password)
        Button("Provision", action: { onCredentials(selectedSSID!, password) })
        Button("Cancel", role: .cancel, action: { password = "" })
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
            ]},
            onCredentials: { _, _ in }
        )

    }
}
