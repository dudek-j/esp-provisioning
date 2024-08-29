import SwiftUI

@main
struct ProvkitApp: App {
    let accessories = Accessories()

    var body: some Scene {
        WindowGroup {
            Root(accessories: accessories)
        }
    }
}

