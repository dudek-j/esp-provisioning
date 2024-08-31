import Foundation
import ESPProvision

private let baseURL = "192.168.4.1:80"
private let versionPath = "proto-ver"


struct NotConnectedError: Error {}
struct ProvisioningError: Error {}

class Provisioning {
    private let accessory: any Accessory
    private let transport: ESPSoftAPTransport
    private var espDevice: ESPDevice?

    init(_ accessory: any Accessory) {
        self.accessory = accessory
        self.transport = ESPSoftAPTransport(baseUrl: baseURL)
    }

    func connect() async throws {
        espDevice = nil

        try await accessory.connect()

        let response = try await send(path: versionPath, data: Data("ESP".utf8))
        let versionInfo = try JSONSerialization.dictionary(response)

        let device = makeESPDevice(versionInfo)
        try await initSession(device)
        espDevice = device
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

    func wifiList() async throws -> [ESPWifiNetwork] {
        guard let espDevice else {
            throw NotConnectedError()
        }

        return try await withCheckedThrowingContinuation { cont in
            espDevice.scanWifiList { wifi, error in
                if let error {
                    cont.resume(throwing: error)
                }

                cont.resume(returning: wifi ?? [])
            }
        }
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
}
