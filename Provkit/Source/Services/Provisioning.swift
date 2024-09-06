import Foundation
import ESPProvision

private let baseURL = "192.168.4.1:80"
private let versionPath = "proto-ver"

struct NotConnectedError: Error {}
struct ProvisioningError: Error {}

class Provisioning {
    private var device: ESPDevice

    init(_ device: ESPDevice) {
        self.device = device
    }

    func wifiList() async throws -> [any WifiNetwork] {
        try await withCheckedThrowingContinuation { cont in
            device.scanWifiList { wifi, error in
                if let error {
                    cont.resume(throwing: error)
                }

                cont.resume(returning: wifi ?? [])
            }
        }
    }
}
