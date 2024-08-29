import ESPProvision

class Provisioning {
    let device: ESPDevice

    init(_ accessory: any Accessory) {
        self.device = ESPDevice(
            name: accessory.ssid!,
            security: .secure,
            transport: .softap,
            network: .wifi
        )
    }

    func connect() async throws {
    }
}

struct ProvisoningError: Error {}

