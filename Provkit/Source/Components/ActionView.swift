import SwiftUI

struct ActionView<Button: View>: View {
    var image: String
    var title: String
    var message: String
    @ViewBuilder let button: Button

    var body: some View {
        VStack {
            Spacer()
            Content()
            Spacer()
            button
                .padding(.top, 110)
        }.padding(64)
    }

    @ViewBuilder
    func Content() -> some View {
        LargeImage(systemName: image)
            .font(.system(size: 150, weight: .light))
            .foregroundStyle(.gray)
        Text(title)
            .font(Font.title.weight(.bold))
            .padding(.vertical, 12)
        Text(message)
            .font(.subheadline)
            .multilineTextAlignment(.center)
    }
}
