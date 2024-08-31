import SwiftUI

struct AlertContent: Identifiable {
    var id: String {
        title + (message ?? "")
    }

    let title: String
    let message: String?

    init(title: String, message: String? = nil) {
        self.title = title
        self.message = message
    }

    var view: Alert {
        Alert(
            title: Text(title),
            message: message.map(Text.init)
        )
    }
}

extension AlertContent: ExpressibleByStringInterpolation {
    init(stringLiteral value: String) {
        self.init(title: value)
    }
}
