import AccessorySetupKit

protocol Accessory: Identifiable, Hashable {
    var id: String { get }
    var ssid: String? { get }
    var displayName: String { get }
    var authorised: Bool { get }

    func connect() async throws
}

extension Accessory {
     public var id: String {
        displayName + (ssid ?? "")
    }

    var detailDescription: String {
        if authorised {
            ssid ?? ""
        } else {
            "Unauthorized"
        }
    }
}


struct PreviewAccessory: Accessory {
    let ssid: String? = String(UUID().uuidString.prefix(6))
    let displayName: String
    let authorised: Bool

    func connect() async throws {}
}
