import SwiftUI

struct CharacterHomeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    @State private var showWardrobe = false
    @State private var showSettings = false

    private var character: CharacterProfile { store.character }
    private var mood: Mood { store.mood }

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header
                        .padding(.top, 16)

                    characterCard

                    dialogueBubble

                    if mood == .sulking {
                        recoveryBlock
                    } else {
                        statsRow
                    }

                    actionButtons
                }
                .padding(.horizontal, MovoMetrics.screenPadding)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showWardrobe) { WardrobeView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }

    private var header: some View {
        HStack {
            MovoWordmark(accent: character.accent.color)
            Spacer()
            StreakBadge(days: store.currentStreakDays, lost: store.currentStreakDays == 0 && !store.workoutLog.isEmpty && store.idleDays >= 1)
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(scheme.movoTextSecondary)
                    .padding(8)
                    .background(Circle().fill(scheme.movoSurfaceAlt))
            }
        }
    }

    private var characterCard: some View {
        RoundedCard(padding: 0) {
            VStack(spacing: 16) {
                ZStack {
                    LinearGradient(
                        colors: [character.accent.color.opacity(0.22), Color.clear],
                        startPoint: .top, endPoint: .bottom
                    )
                    CharacterPortrait(accent: character.accent.color, stage: character.stage, mood: mood, gear: character.gear(), targetHeight: 190)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: MovoMetrics.cardRadius, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(character.name.isEmpty ? "Your Movo" : character.name)
                            .font(.movoDisplay(24))
                            .foregroundStyle(scheme.movoTextPrimary)
                        Spacer()
                        Text("\(character.stage.displayName) · stage \(character.stage.rawValue)")
                            .font(.movoBody(12, weight: .semibold))
                            .foregroundStyle(character.accent.color)
                    }

                    MovoProgressBar(progress: character.progressToNextStage, accent: character.accent.color)

                    HStack {
                        Text("\(character.totalPoints) pts")
                            .font(.movoBody(12, weight: .semibold))
                            .foregroundStyle(scheme.movoTextSecondary)
                        Spacer()
                        if let next = character.stage.next {
                            Text("\(character.pointsToNextStage) to \(next.displayName)")
                                .font(.movoBody(12))
                                .foregroundStyle(scheme.movoTextSecondary)
                        } else {
                            Text("Max stage reached")
                                .font(.movoBody(12))
                                .foregroundStyle(scheme.movoTextSecondary)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { showWardrobe = true }
    }

    private var dialogueBubble: some View {
        RoundedCard {
            Text("\u{201C}\(store.currentDialogue)\u{201D}")
                .font(.movoBody(14, weight: .medium))
                .foregroundStyle(scheme.movoTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("— \(character.name.isEmpty ? "Movo" : character.name), just now")
                .font(.movoBody(11))
                .foregroundStyle(scheme.movoTextSecondary)
        }
    }

    private var statsRow: some View {
        RoundedCard {
            HStack {
                StatTile(label: "This week", value: "\(store.weeklySessionsCount)")
                StatTile(label: "Points", value: "\(character.totalPoints)", valueColor: character.accent.color)
                StatTile(label: "Crew rank", value: "#\(store.crewRank)")
            }
        }
    }

    private var recoveryBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Get back in — smallest possible step")
            RecoveryActionRow(title: "10 squats, right now", points: store.pointsForExercise(.squats, amount: 10)) {
                store.logQuickRecovery(exercise: .squats, amount: 10)
            }
            RecoveryActionRow(title: "A 10-minute walk", points: store.pointsForExercise(.walk, amount: 1.3)) {
                store.logQuickRecovery(exercise: .walk, amount: 1.3)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            MovoPillButton(
                title: mood == .sulking ? "Cheer \(character.name.isEmpty ? "Movo" : character.name) up" : "+ Log a workout",
                accent: character.accent.color,
                action: { store.presentWorkoutLog() }
            )
            Button {
                store.isSessionFlowPresented = true
            } label: {
                Text("Start a timed session →")
                    .font(.movoBody(13, weight: .semibold))
                    .foregroundStyle(scheme.movoTextSecondary)
            }
        }
    }
}

private struct RecoveryActionRow: View {
    @Environment(\.colorScheme) private var scheme
    var title: String
    var points: Int
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.movoBody(14, weight: .medium))
                    .foregroundStyle(scheme.movoTextPrimary)
                Spacer()
                Text("+\(points)")
                    .font(.movoBody(14, weight: .bold))
                    .foregroundStyle(Color.movoLime)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).fill(scheme.movoSurface))
            .overlay(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).strokeBorder(scheme.movoBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let store = AppStore()
    store.createCharacter(name: "Bibo", accent: .lime)
    return CharacterHomeView().environmentObject(store)
}
