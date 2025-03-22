import AccessorySetupKit
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

extension ASAccessory: @retroactive Identifiable, Accessory {
    var authorised: Bool {
        state == .authorized
    }

    func connect() async throws {
        do {
            try await NEHotspotConfigurationManager.shared.joinAccessoryHotspotWithoutSecurity(self)
            try await Task.sleep(for: .seconds(3))
        } catch let error where (error as NSError).code == NEHotspotConfigurationError.alreadyAssociated.rawValue {
            return
        }
    }
}

