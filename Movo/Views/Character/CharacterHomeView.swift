import SwiftUI

struct CharacterHomeView: View {
    @EnvironmentObject var store: AppStore

    private var character: CharacterProfile { store.character }

    var body: some View {
        ZStack {
            Color.movoBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text(character.name.uppercased())
                            .font(.movoHeader(32))
                            .foregroundStyle(Color.movoTextPrimary)
                        Text(character.stage.displayName.uppercased())
                            .font(.movoMono(14, weight: .semibold))
                            .foregroundStyle(Color.movoVolt)
                    }
                    .padding(.top, 24)

                    CharacterShapeView(
                        bodyColor: character.bodyColor,
                        outfitColor: character.outfitColor,
                        stage: character.stage,
                        growthScale: character.growthScale
                    )
                    .frame(height: 260)

                    BracketPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("TOTAL POINTS")
                                    .font(.movoMono(12, weight: .semibold))
                                    .foregroundStyle(Color.movoTextSecondary)
                                Spacer()
                                Text("\(character.totalPoints)")
                                    .font(.movoMono(20, weight: .bold))
                                    .foregroundStyle(Color.movoVolt)
                            }

                            SegmentedProgressBar(progress: character.progressToNextStage)

                            if let next = character.stage.next {
                                Text("\(next.threshold - character.totalPoints) PTS TO \(next.displayName.uppercased())")
                                    .font(.movoMono(11))
                                    .foregroundStyle(Color.movoTextSecondary)
                            } else {
                                Text("MAX STAGE REACHED")
                                    .font(.movoMono(11))
                                    .foregroundStyle(Color.movoTextSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    BracketPanel(accent: .movoCoral) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ACCESSORIES")
                                .font(.movoMono(12, weight: .semibold))
                                .foregroundStyle(Color.movoTextSecondary)
                            HStack(spacing: 16) {
                                AccessoryBadge(label: "Headband", unlocked: character.stage.hasHeadband)
                                AccessoryBadge(label: "Cape", unlocked: character.stage.hasCape)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

private struct AccessoryBadge: View {
    var label: String
    var unlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                .foregroundStyle(unlocked ? Color.movoVolt : Color.movoTextSecondary)
            Text(label.uppercased())
                .font(.movoMono(10))
                .foregroundStyle(unlocked ? Color.movoTextPrimary : Color.movoTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.movoBackground)
        .overlay(Rectangle().strokeBorder(Color.movoPanelBorder))
    }
}

#Preview {
    let store = AppStore()
    store.createCharacter(name: "Blaze", bodyColorHex: "#5B8DEF", outfitColorHex: "#FF6B5E")
    return CharacterHomeView().environmentObject(store)
}
