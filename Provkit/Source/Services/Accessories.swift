import Foundation
import ESPProvision
import AccessorySetupKit
import NetworkExtension

@Observable
class Accessories {
    private(set) var available: [ASAccessory]?
    private let session = ASAccessorySession()

    init() {
        self.session.activate(on: .main, eventHandler: accessoryEvent)
    }

    func discover() {
        Task {
            try! await session.showPicker(for: [.vinylPlayer])
        }
    }

    private func accessoryEvent(event: ASAccessoryEvent) {
        available = session.accessories
    }
}

extension ASPickerDisplayItem {
    static var vinylPlayer = {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.ssid  = "dudek-sonos-vinyl"

        return ASPickerDisplayItem(
            name: "Sonos Vinyl",
            productImage: UIImage(named: "recordPlayer")!,
            descriptor: descriptor
        )
    }()
}
