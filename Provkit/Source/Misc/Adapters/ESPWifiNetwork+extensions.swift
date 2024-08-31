import ESPProvision

extension ESPWifiNetwork: @retroactive Identifiable {}
extension ESPWifiNetwork: @retroactive Hashable {}
extension ESPWifiNetwork: @retroactive Equatable {}
extension ESPWifiNetwork: WifiNetwork {
    public func hash(into hasher: inout Hasher) {

    }
    public static func == (lhs: ESPWifiNetwork, rhs: ESPWifiNetwork) -> Bool {
        return false
    }

    var requiresPassword: Bool {
        auth == .open
    }
}

