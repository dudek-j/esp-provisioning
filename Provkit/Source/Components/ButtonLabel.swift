import SwiftUI

struct ButtonLabel: View {
    @Binding var loading: Bool

    init(title: String, loading: Binding<Bool> = .constant(false)) {
        self.title = title
        self._loading = loading
    }

    let title: String

    var body: some View {
        Title()
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
    }

    private func Title() -> some View {
        Group {
            if loading {
                ProgressView().controlSize(.regular)
            } else {
                Text(title)
            }
        }
    }
}

