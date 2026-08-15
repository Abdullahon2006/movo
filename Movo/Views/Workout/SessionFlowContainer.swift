import SwiftUI

/// Hosts the timed-session wizard: pick a template, run it live, then cooldown and post.
/// Presented as a sheet from anywhere via `store.isSessionFlowPresented`.
struct SessionFlowContainer: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    private enum Phase {
        case start
        case live(WorkoutSessionTemplate, inviteCrew: Bool)
        case cooldown(WorkoutSessionTemplate)
    }

    @State private var phase: Phase = .start

    var body: some View {
        Group {
            switch phase {
            case .start:
                SessionStartView(
                    onStart: { template, inviteCrew in
                        store.workoutInProgress = true
                        withAnimation { phase = .live(template, inviteCrew: inviteCrew) }
                    },
                    onClose: { dismiss() }
                )
            case .live(let template, let inviteCrew):
                LiveHoldView(
                    template: template,
                    inviteCrew: inviteCrew,
                    onFinished: {
                        withAnimation { phase = .cooldown(template) }
                    },
                    onClose: {
                        store.workoutInProgress = false
                        dismiss()
                    }
                )
            case .cooldown(let template):
                CooldownView(
                    precedingPoints: store.pointsForSession(template),
                    onFinish: { finish(template: template) },
                    onClose: {
                        store.workoutInProgress = false
                        dismiss()
                    }
                )
            }
        }
    }

    private func finish(template: WorkoutSessionTemplate) {
        store.workoutInProgress = false
        let livePts = store.logSession(template, postToFeed: false)
        let cooldownPts = store.logSession(SessionLibrary.cooldown, postToFeed: false)
        let total = livePts + cooldownPts
        store.insertMyFeedPost(kind: .session, detail: "finished \(template.name) + cooldown", points: total)
        dismiss()
    }
}

#Preview {
    SessionFlowContainer().environmentObject(AppStore())
}
