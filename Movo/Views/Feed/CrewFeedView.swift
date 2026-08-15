import SwiftUI

struct CrewFeedView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    header

                    if let drop = store.activeDrop {
                        dropBanner(drop)
                    }

                    if let live = store.liveSessionMember {
                        liveSessionBanner(live)
                    }

                    VStack(spacing: 14) {
                        ForEach(store.feed) { post in
                            FeedPostCard(post: post, onReact: { emoji in store.react(to: post.id, emoji: emoji) })
                        }
                    }
                }
                .padding(.horizontal, MovoMetrics.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .onAppear { store.startSimulatedCrewActivity() }
        .onDisappear { store.stopSimulatedCrewActivity() }
    }

    private var header: some View {
        HStack {
            Text("Crew feed")
                .font(.movoDisplay(28))
                .foregroundStyle(scheme.movoTextPrimary)
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(Color.movoLime).frame(width: 7, height: 7)
                Text("\(store.crewOnlineCount) online")
                    .font(.movoBody(12, weight: .semibold))
                    .foregroundStyle(scheme.movoTextSecondary)
            }
        }
    }

    private func dropBanner(_ drop: MovoDrop) -> some View {
        let minutesLeft = max(0, Int(drop.expiresAt.timeIntervalSinceNow / 60))
        let secondsLeft = max(0, Int(drop.expiresAt.timeIntervalSinceNow))
        let label = minutesLeft > 0 ? "\(minutesLeft) min" : "\(secondsLeft)s"
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Movo drop")
                    .font(.movoBody(12, weight: .bold))
                    .foregroundStyle(scheme.movoTextPrimary)
                Text("\(label) to post \(Int(drop.amount)) \(drop.exercise.displayName.lowercased())")
                    .font(.movoBody(11))
                    .foregroundStyle(scheme.movoTextSecondary)
            }
            Spacer()
            Button("Go") { store.acceptDrop() }
                .font(.movoBody(13, weight: .bold))
                .foregroundStyle(.black.opacity(0.85))
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.movoAmber))
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).fill(Color.movoAmber.opacity(0.16)))
    }

    private func liveSessionBanner(_ member: CrewMember) -> some View {
        Button {
            store.isSessionFlowPresented = true
        } label: {
            HStack(spacing: 10) {
                AvatarBubble(name: member.name, colorHex: member.colorHex, size: 30)
                (Text("\(member.name) started a live session · ") + Text("Join and train together").foregroundStyle(Color.movoLime))
                    .font(.movoBody(12, weight: .medium))
                    .foregroundStyle(scheme.movoTextPrimary)
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).fill(scheme.movoSurface))
        }
        .buttonStyle(.plain)
    }
}

private struct FeedPostCard: View {
    @Environment(\.colorScheme) private var scheme
    var post: FeedPost
    var onReact: (String) -> Void

    private let reactionOptions = ["🔥", "💪", "🤩"]

    var body: some View {
        RoundedCard {
            HStack(spacing: 12) {
                AvatarBubble(name: post.authorName, colorHex: post.authorColorHex)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(post.authorName)
                            .font(.movoBody(13, weight: .bold))
                            .foregroundStyle(scheme.movoTextPrimary)
                        Text(post.date, style: .relative)
                            .font(.movoBody(11))
                            .foregroundStyle(scheme.movoTextSecondary)
                    }
                    Text(post.headline)
                        .font(.movoBody(12))
                        .foregroundStyle(scheme.movoTextSecondary)
                }
                Spacer()
            }

            if post.hasPhoto {
                RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous)
                    .fill(Color.black.opacity(0.85))
                    .frame(height: 160)
                    .overlay(alignment: .topLeading) {
                        Text("front camera — mid-\(post.detail.split(separator: " ").last ?? "set")")
                            .font(.movoBody(9))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(8)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        AvatarBubble(name: post.authorName, colorHex: post.authorColorHex, size: 34)
                            .padding(8)
                    }
            }

            if post.kind != .liveSession {
                HStack(spacing: 14) {
                    ForEach(reactionOptions, id: \.self) { emoji in
                        Button { onReact(emoji) } label: {
                            HStack(spacing: 4) {
                                Text(emoji)
                                if let count = post.reactions[emoji], count > 0 {
                                    Text("\(count)")
                                        .font(.movoBody(11, weight: .semibold))
                                        .foregroundStyle(scheme.movoTextSecondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                    if post.commentCount > 0 {
                        Text("\(post.commentCount) comments")
                            .font(.movoBody(11))
                            .foregroundStyle(scheme.movoTextSecondary)
                    }
                }
            }
        }
    }
}

#Preview {
    CrewFeedView().environmentObject(AppStore())
}
