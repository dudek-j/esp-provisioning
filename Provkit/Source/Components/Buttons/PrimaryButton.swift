import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let loading: Bool
    let disabled: Bool

    init(
        title: String,
        action: @escaping () -> Void,
        loading: Bool = false,
        disabled: Bool = false
    ) {
        self.title = title
        self.action = action
        self.loading = loading
        self.disabled = disabled
    }

    var body: some View {
        Button(
            action: action,
            label: { ButtonLabel(title: title, loading: loading) }
        )
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(loading || disabled)
    }
}

#Preview {
    VStack {
        PrimaryButton(title: "Try again", action: {})
        PrimaryButton(title: "Try again", action: {}, disabled: true)
        PrimaryButton(title: "Try again", action: {}, loading: true)
        PrimaryButton(title: "Try again", action: {}, loading: true, disabled: true)
    }.padding(64)
}
