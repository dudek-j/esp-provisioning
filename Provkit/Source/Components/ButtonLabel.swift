import SwiftUI

struct ButtonLabel: View {
    let title: String
    let loading: Bool

    init(title: String, loading: Bool = false) {
        self.loading = loading
        self.title = title
    }

    var body: some View {
        Title()
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func Title() -> some View {
        if loading {
            ProgressView().controlSize(.regular)
        } else {
            Text(title)
        }
    }
}

