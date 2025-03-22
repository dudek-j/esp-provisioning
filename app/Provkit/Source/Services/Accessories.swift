import Foundation
import ESPProvision
import AccessorySetupKit
import NetworkExtension

@Observable
class Accessories {
    private(set) var available: [ASAccessory]?
    private let session = ASAccessorySession()

    init() {
        activateSession()
    }

    private func activateSession() {
        session.activate(
            on: .main,
            eventHandler: { [weak self] _ in
                guard let self else { return }
                available = session.accessories
            }
        )
    }

    func discover() {
        Task {
            try! await session.showPicker(for: [.vinylPlayer])
        }
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
