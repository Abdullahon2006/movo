import SwiftUI

struct LevelUpModalView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    var event: LevelUpEvent
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 18) {
                Text("STAGE \(event.stage.rawValue) UNLOCKED")
                    .font(.movoBody(12, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Color.movoLime)

                Text("\(store.character.name.isEmpty ? "Your Movo" : store.character.name) is a \(event.stage.displayName)")
                    .font(.movoDisplay(24))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(scheme.movoTextPrimary)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(colors: [store.character.accent.color.opacity(0.35), .clear],
                                           center: .center, startRadius: 10, endRadius: 120)
                        )
                        .frame(width: 220, height: 220)
                    CharacterPortrait(accent: store.character.accent.color, stage: event.stage, mood: .happy, gear: store.character.gear(), targetHeight: 190)
                }

                if !event.unlockedItems.isEmpty {
                    HStack(spacing: 10) {
                        ForEach(event.unlockedItems, id: \.self) { item in
                            Text(item)
                                .font(.movoBody(12, weight: .semibold))
                                .foregroundStyle(scheme.movoTextPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(scheme.movoSurfaceAlt))
                        }
                    }
                }

                VStack(spacing: 10) {
                    MovoPillButton(title: "Post to crew feed", accent: .movoLime) {
                        postCelebration()
                        onDismiss()
                    }
                    MovoGhostButton(title: "Maybe later", action: onDismiss)
                }
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: MovoMetrics.cardRadius, style: .continuous).fill(scheme.movoSurface))
            .overlay(RoundedRectangle(cornerRadius: MovoMetrics.cardRadius, style: .continuous).strokeBorder(scheme.movoBorder, lineWidth: 1))
            .padding(.horizontal, 28)
        }
    }

    private func postCelebration() {
        store.feed.insert(FeedPost(
            authorName: store.character.name.isEmpty ? "You" : store.character.name,
            authorColorHex: store.character.accent.color.toHex(),
            stage: event.stage,
            kind: .workout,
            detail: "reached \(event.stage.displayName)",
            points: 0,
            isMe: true
        ), at: 0)
    }
}

#Preview {
    LevelUpModalView(event: LevelUpEvent(stage: .champion, unlockedItems: ["+1 Arms", "Gold band", "Crown"]), onDismiss: {})
        .environmentObject(AppStore())
}
