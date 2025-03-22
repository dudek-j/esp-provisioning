import SwiftUI

struct ProvisioningProgress: View {
    @Binding var loading: Bool
    var sendCredentials: () -> AsyncThrowingStream<ConfigApplied, Error>
    var tryAgain: () -> Void
    var onSuccess: () -> Void

    @State private var progress = ProgressState()
    @State var alert: AlertContent?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            LargeImage(systemName: "rectangle.connected.to.line.below")
            ProgressIndicators()
            Spacer()
            TryAgain()
                .padding(.top, 64)
        }
        .padding(64)
        .alert(item: $alert) { $0.view }
        .task(send)
    }

    @Sendable
    private func send() async {
        loading = true

        progress.start()
        do {
            for try await _ in sendCredentials() { progress.received() }
            onSuccess()
        } catch {
            progress.failure()
            alert = "Failed to provision"
        }

        loading = false
    }

    private func ProgressIndicators() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressLabel(title: "Sending credentials", state: progress.sending)
            ProgressLabel(title: "Verifying connection", state: progress.verifying)
        }
    }

    private func TryAgain() -> some View {
        PrimaryButton(title: "Try again", action: tryAgain)
            .opacity(loading ? 0 : 1)
    }

    private struct ProgressState {
        var sending: ProgressLabel.State?
        var verifying: ProgressLabel.State?

        mutating func start() {
            verifying = .loading
            sending = nil
        }

        mutating func received() {
            sending = .done(success: true)
            verifying = .loading
        }

        mutating func failure() {
            if case .loading = sending {
                sending = .done(success: false)
            }

            if case .loading = verifying {
                verifying = .done(success: false)
            }
        }
    }
}

private struct ProgressLabel: View {
    let title: String
    let state: State?

    var body: some View {
        Label(title: { Text(title)}, icon: Icon)
    }

    @ViewBuilder
    private func Icon() -> some View {
        if case .done(let success) = state {
            Image(systemName: success ? "checkmark" : "xmark")
                .foregroundStyle(success ? .green : .red)
        } else {
            ProgressView()
                .opacity(state == nil ? 0 : 1)
        }
    }

    enum State {
        case done(success: Bool)
        case loading
    }
}

#Preview {
    NavigationStack {
        ProvisioningProgress(
            loading: .constant(false),
            sendCredentials: { AsyncThrowingStream { _ in } },
            tryAgain: {},
            onSuccess: {}
        )
    }
}

#Preview {
    NavigationStack {
        ProvisioningProgress(
            loading: .constant(true),
            sendCredentials: { AsyncThrowingStream { _ in } },
            tryAgain: {},
            onSuccess: {}
        )
    }
}
