import ESPProvision
import SwiftUI

protocol WifiNetwork: Identifiable, Hashable  {
    var ssid: String { get }
    var rssi: Int32 { get }
    var requiresPassword: Bool { get }
}

extension WifiNetwork {
    public var id: String {
        ssid
    }

    var styling: (color: Color, percentage: Double) {
        if rssi > -50 {
            (.green, 1.0)
        } else if rssi > -60 {
            (.yellow, 0.6)
        } else if rssi > -67 {
            (.orange, 0.3)
        } else {
            (.red, 0.1)
        }
    }
}

struct PreviewNetwork: WifiNetwork {
    let ssid: String = String(UUID().uuidString.prefix(8))
    let rssi: Int32
    let requiresPassword: Bool = true
}
