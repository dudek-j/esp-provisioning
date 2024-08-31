import Foundation

extension JSONSerialization {
    static func dictionary(_ data: Data) throws -> NSDictionary {
        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        return json as! NSDictionary
    }
}
