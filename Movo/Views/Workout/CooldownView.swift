import SwiftUI

struct CooldownView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme

    var precedingPoints: Int = 0
    var onFinish: () -> Void
    var onClose: () -> Void

    private let moves = SessionLibrary.cooldown.moves
    @State private var currentIndex = 0
    @State private var secondsLeft = SessionLibrary.cooldown.moves.first?.seconds ?? 30

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var currentMove: SessionMove { moves[currentIndex] }

    private var cooldownEarnedSoFar: Int {
        let completed = moves.prefix(currentIndex).reduce(0.0) { $0 + (Double($1.seconds) / 10.0) * $1.weight }
        let elapsed = Double(currentMove.seconds - secondsLeft)
        let partial = (elapsed / 10.0) * currentMove.weight
        return max(0, Int(((completed + partial) * store.streakBonus() * store.character.multiplier).rounded()))
    }

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    ZStack {
                        LinearGradient(colors: [Color.movoBlue.opacity(0.18), .clear], startPoint: .top, endPoint: .bottom)
                        CharacterPortrait(accent: store.character.accent.color, stage: store.character.stage, mood: .wrecked, gear: store.character.gear(), targetHeight: 160)
                    }
                    .frame(height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: MovoMetrics.cardRadius, style: .continuous))

                    RoundedCard(borderColor: .movoBlue) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(currentMove.name)
                                    .font(.movoBody(16, weight: .semibold))
                                    .foregroundStyle(scheme.movoTextPrimary)
                                Text(currentMove.cue)
                                    .font(.movoBody(12))
                                    .foregroundStyle(scheme.movoTextSecondary)
                            }
                            Spacer()
                            Text(timeString(secondsLeft))
                                .font(.movoDisplay(24))
                                .foregroundStyle(Color.movoBlue)
                        }
                        MovoProgressBar(
                            progress: 1 - (Double(secondsLeft) / Double(max(currentMove.seconds, 1))),
                            accent: .movoBlue
                        )
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeading(title: "Sequence")
                        VStack(spacing: 8) {
                            ForEach(Array(moves.enumerated()), id: \.offset) { idx, move in
                                SequenceRow(move: move, state: idx < currentIndex ? .done : (idx == currentIndex ? .current : .pending))
                            }
                        }
                    }

                    RoundedCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Session total")
                                    .font(.movoBody(13, weight: .semibold))
                                    .foregroundStyle(scheme.movoTextPrimary)
                                Text(SessionLibrary.cooldown.summary)
                                    .font(.movoBody(11))
                                    .foregroundStyle(scheme.movoTextSecondary)
                            }
                            Spacer()
                            Text("+\(precedingPoints + cooldownEarnedSoFar)")
                                .font(.movoDisplay(22))
                                .foregroundStyle(Color.movoLime)
                        }
                    }
                }
                .padding(.horizontal, MovoMetrics.screenPadding)
                .padding(.bottom, 16)
            }

            VStack {
                Spacer()
                MovoPillButton(title: "Finish & post to crew", accent: .movoLime, action: onFinish)
                    .padding(.horizontal, MovoMetrics.screenPadding)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(colors: [.clear, scheme.movoBackground.opacity(0.9), scheme.movoBackground], startPoint: .top, endPoint: .bottom)
                            .frame(height: 90)
                            .allowsHitTesting(false)
                    )
            }
        }
        .onReceive(timer) { _ in tick() }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Cooldown")
                    .font(.movoDisplay(26))
                    .foregroundStyle(scheme.movoTextPrimary)
                Text("Four minutes. Still earns points.")
                    .font(.movoBody(13))
                    .foregroundStyle(scheme.movoTextSecondary)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(scheme.movoTextSecondary)
                    .padding(8)
                    .background(Circle().fill(scheme.movoSurfaceAlt))
            }
        }
        .padding(.top, 18)
    }

    private func tick() {
        if secondsLeft > 0 {
            secondsLeft -= 1
        } else if currentIndex + 1 < moves.count {
            currentIndex += 1
            secondsLeft = moves[currentIndex].seconds
        }
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

private enum RowState { case done, current, pending }

private struct SequenceRow: View {
    @Environment(\.colorScheme) private var scheme
    var move: SessionMove
    var state: RowState

    var body: some View {
        HStack {
            Image(systemName: state == .done ? "checkmark.circle.fill" : (state == .current ? "circle.inset.filled" : "circle"))
                .foregroundStyle(state == .done ? Color.movoLime : (state == .current ? Color.movoBlue : scheme.movoTextSecondary))
            Text(move.name)
                .font(.movoBody(13, weight: state == .current ? .semibold : .regular))
                .foregroundStyle(state == .pending ? scheme.movoTextSecondary : scheme.movoTextPrimary)
            Spacer()
            Text("\(move.seconds)s")
                .font(.movoBody(12))
                .foregroundStyle(scheme.movoTextSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(state == .current ? Color.movoBlue.opacity(0.12) : scheme.movoSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(state == .current ? Color.movoBlue : scheme.movoBorder, lineWidth: state == .current ? 1.5 : 1)
        )
    }
}

#Preview {
    CooldownView(precedingPoints: 180, onFinish: {}, onClose: {}).environmentObject(AppStore())
}
