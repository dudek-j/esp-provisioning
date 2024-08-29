import SwiftUI

struct ActionView<Button: View>: View {
    var image: Image
    var title: String
    var message: String
    @ViewBuilder let action: Button

    var body: some View {
        VStack {
            Spacer()
            Content()
            Spacer()
            Action()
                .padding(.top, 110)
        }.padding(64)
    }

    @ViewBuilder
    func Content() -> some View {
        image
            .font(.system(size: 150, weight: .light))
            .foregroundStyle(.gray)
        Text(title)
            .font(Font.title.weight(.bold))
            .padding(.vertical, 12)
        Text(message)
            .font(.subheadline)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    func Action() -> some View {
        action
            .buttonStyle(.bordered)
            .controlSize(.large)
    }
}
