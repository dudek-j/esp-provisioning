import Foundation
import ESPProvision

private let baseURL = "192.168.4.1:80"
private let versionPath = "proto-ver"

struct NotConnectedError: Error {}
struct ProvisioningError: Error {}
struct ConfigApplied {}

typealias SendCredentials = () -> AsyncThrowingStream<ConfigApplied, Error>

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

    func send(_ credentials: Credentials) -> AsyncThrowingStream<ConfigApplied, Error> {
        AsyncThrowingStream { cont in
            device.provision(ssid: credentials.ssid, passPhrase: credentials.password) { status in
                switch status {
                case .success:
                    cont.finish()
                case .failure(let error):
                    cont.finish(throwing: error)
                case .configApplied:
                    cont.yield(ConfigApplied())
                }
            }
        }
    }
}

