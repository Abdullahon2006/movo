import SwiftUI

struct CrewFeedView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ZStack {
            Color.movoBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("CREW FEED")
                            .font(.movoHeader(30))
                            .foregroundStyle(Color.movoTextPrimary)
                        Spacer()
                        Circle()
                            .fill(Color.movoVolt)
                            .frame(width: 8, height: 8)
                        Text("LIVE")
                            .font(.movoMono(11, weight: .semibold))
                            .foregroundStyle(Color.movoVolt)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    if store.feed.isEmpty {
                        Text("No posts yet — log a workout to hit the feed.")
                            .font(.movoMono(13))
                            .foregroundStyle(Color.movoTextSecondary)
                            .padding(.top, 60)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(store.feed) { post in
                                FeedPostCard(post: post)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }
}

private struct FeedPostCard: View {
    var post: FeedPost

    var body: some View {
        BracketPanel(accent: .movoCoral) {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color.movoSteel)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(post.characterName.prefix(1)).uppercased())
                            .font(.movoHeader(16))
                            .foregroundStyle(Color.black)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(post.headline)
                        .font(.movoMono(13, weight: .semibold))
                        .foregroundStyle(Color.movoTextPrimary)
                    Text(post.date, style: .relative)
                        .font(.movoMono(11))
                        .foregroundStyle(Color.movoTextSecondary)
                }

                Spacer()

                Image(systemName: post.exercise.symbolName)
                    .foregroundStyle(Color.movoCoral)
            }
        }
    }
}

#Preview {
    CrewFeedView().environmentObject(AppStore())
}
