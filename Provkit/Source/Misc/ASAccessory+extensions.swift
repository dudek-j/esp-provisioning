import AccessorySetupKit
import NetworkExtension

extension ASAccessory: @retroactive Identifiable, Accessory {
    var authorised: Bool {
        state == .authorized
    }

    func connect() async throws {
        do {
            try await NEHotspotConfigurationManager.shared.joinAccessoryHotspotWithoutSecurity(self)
        } catch let error where (error as NSError).code == NEHotspotConfigurationError.alreadyAssociated.rawValue {
            return
        }
    }
}

