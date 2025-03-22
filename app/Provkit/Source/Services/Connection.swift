import Foundation
import ESPProvision

private let baseURL = "192.168.4.1:80"
private let versionPath = "proto-ver"

class Connection {
    private let accessory: any Accessory
    private let transport: ESPSoftAPTransport

    init(_ accessory: any Accessory) {
        self.accessory = accessory
        self.transport = ESPSoftAPTransport(baseUrl: baseURL)
    }

    func establish() async throws -> ESPDevice {
        try await accessory.connect()

        let response = try await send(path: versionPath, data: Data("ESP".utf8))
        let versionInfo = try JSONSerialization.dictionary(response)

        let device = makeESPDevice(versionInfo)
        try await initSession(device)

        return device
    }

    private func send(path: String, data: Data) async throws -> Data {
        try await withCheckedThrowingContinuation { cont in
            transport.SendConfigData(path: versionPath, data: data) { data, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }

                cont.resume(returning: data!)
            }
        }
    }

    private func makeESPDevice(_ versionInfo: NSDictionary) -> ESPDevice {
        let device = ESPDevice(
            name: accessory.ssid ?? "",
            security: .secure,
            transport: .softap
        )

        device.espSoftApTransport = transport
        device.versionInfo = versionInfo
        device.capabilities = (versionInfo["prov"] as? NSDictionary)?["cap"] as? [String]

        return device
    }

    private func initSession(_ device: ESPDevice) async throws {
        try await withCheckedThrowingContinuation { cont in
            device.initialiseSession(sessionPath: nil) { status in
                guard case .connected = status else {
                    cont.resume(throwing: ProvisioningError())
                    return
                }

                cont.resume()
            }
        } as Void
    }
}
