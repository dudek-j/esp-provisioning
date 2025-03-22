import SwiftUI
import AccessorySetupKit

struct Root: View {
    let accessories: Accessories

    var body: some View {
        switch accessories.available {
        case .some(let accessories) where accessories.isEmpty:
            DiscoverAccessories(discover: self.accessories.discover)
        case .some(let accessories):
            AccessoryList(accessories: accessories)
        case .none:
            EmptyView()
        }
    }
}

