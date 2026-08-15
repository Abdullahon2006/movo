import SwiftUI

struct LiveHoldView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme

    var template: WorkoutSessionTemplate
    var inviteCrew: Bool
    var onFinished: () -> Void
    var onClose: () -> Void

    @State private var currentIndex = 0
    @State private var secondsLeft: Int
    @State private var isPaused = false
    @State private var heartRate = 132

    init(template: WorkoutSessionTemplate, inviteCrew: Bool, onFinished: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.template = template
        self.inviteCrew = inviteCrew
        self.onFinished = onFinished
        self.onClose = onClose
        _secondsLeft = State(initialValue: template.moves.first?.seconds ?? 30)
    }

    private var currentMove: SessionMove { template.moves[currentIndex] }
    private var nextMove: SessionMove? {
        currentIndex + 1 < template.moves.count ? template.moves[currentIndex + 1] : nil
    }

    private var secondsRemainingInSession: Int {
        let completed = template.moves.prefix(currentIndex).reduce(0) { $0 + $1.seconds }
        let elapsedInCurrent = currentMove.seconds - secondsLeft
        return max(0, template.totalSeconds - completed - elapsedInCurrent)
    }

    private var earnedSoFar: Int {
        let completed = template.moves.prefix(currentIndex).reduce(0.0) { $0 + (Double($1.seconds) / 10.0) * $1.weight }
        let elapsedInCurrent = Double(currentMove.seconds - secondsLeft)
        let partial = (elapsedInCurrent / 10.0) * currentMove.weight
        return max(0, Int(((completed + partial) * store.streakBonus() * store.character.multiplier).rounded()))
    }

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()

            VStack(spacing: 18) {
                header

                VStack(spacing: 4) {
                    Text(timeString(secondsLeft))
                        .font(.movoDisplay(56))
                        .foregroundStyle(scheme.movoTextPrimary)
                    Text(currentMove.name.uppercased())
                        .font(.movoBody(13, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(store.character.accent.color)
                }

                progressDots

                RoundedCard {
                    Text("\u{201C}\(store.currentDialogue)\u{201D}")
                        .font(.movoBody(13, weight: .medium))
                        .foregroundStyle(scheme.movoTextPrimary)
                }

                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [store.character.accent.color.opacity(0.3), .clear], center: .center, startRadius: 10, endRadius: 130))
                        .frame(width: 220, height: 220)
                    CharacterPortrait(accent: store.character.accent.color, stage: store.character.stage, mood: .firedUp, gear: store.character.gear(), targetHeight: 180)
                }

                RoundedCard {
                    HStack {
                        StatTile(label: "Heart", value: "\(heartRate)")
                        StatTile(label: "Earned", value: "+\(earnedSoFar)", valueColor: .movoLime)
                        StatTile(label: "Left", value: timeString(secondsRemainingInSession))
                    }
                }

                if inviteCrew {
                    crewPresence
                }

                if let nextMove {
                    HStack {
                        Text("Next up")
                            .font(.movoBody(12))
                            .foregroundStyle(scheme.movoTextSecondary)
                        Spacer()
                        Text("\(nextMove.name) · \(nextMove.seconds)s")
                            .font(.movoBody(12, weight: .semibold))
                            .foregroundStyle(scheme.movoTextPrimary)
                    }
                }

                Spacer(minLength: 0)

                HStack(spacing: 12) {
                    Button { isPaused.toggle() } label: {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .foregroundStyle(scheme.movoTextPrimary)
                            .frame(width: 52, height: 52)
                            .background(Circle().fill(scheme.movoSurfaceAlt))
                    }

                    MovoPillButton(
                        title: nextMove == nil ? "Done — finish" : "Done — next hold",
                        accent: store.character.accent.color,
                        action: advance
                    )
                }
            }
            .padding(.horizontal, MovoMetrics.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .onReceive(timer) { _ in tick() }
    }

    private var header: some View {
        HStack {
            Text("\(template.name.uppercased()) · HOLD \(currentIndex + 1) OF \(template.moves.count)")
                .font(.movoBody(11, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(scheme.movoTextSecondary)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(scheme.movoTextSecondary)
                    .padding(8)
                    .background(Circle().fill(scheme.movoSurfaceAlt))
            }
        }
    }

    private var progressDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<template.moves.count, id: \.self) { idx in
                Capsule()
                    .fill(idx < currentIndex ? Color.movoLime : (idx == currentIndex ? store.character.accent.color : scheme.movoSurfaceAlt))
                    .frame(height: 6)
            }
        }
    }

    private var crewPresence: some View {
        let names = Array(CrewMember.roster.prefix(3)).map(\.name)
        let joined = names.count > 1
            ? names.dropLast().joined(separator: ", ") + " and " + names.last!
            : (names.first ?? "")
        return HStack(spacing: 8) {
            HStack(spacing: -8) {
                ForEach(CrewMember.roster.prefix(3)) { member in
                    AvatarBubble(name: member.name, colorHex: member.colorHex, size: 26)
                        .overlay(Circle().strokeBorder(scheme.movoBackground, lineWidth: 2))
                }
            }
            Text("\(joined) are holding this with you")
                .font(.movoBody(11))
                .foregroundStyle(scheme.movoTextSecondary)
            Spacer(minLength: 0)
        }
    }

    private func tick() {
        guard !isPaused else { return }
        heartRate = max(110, min(172, heartRate + Int.random(in: -4...5)))
        if secondsLeft > 0 {
            secondsLeft -= 1
        } else {
            advance()
        }
    }

    private func advance() {
        if currentIndex + 1 < template.moves.count {
            currentIndex += 1
            secondsLeft = template.moves[currentIndex].seconds
        } else {
            onFinished()
        }
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    LiveHoldView(template: SessionLibrary.coreBurner, inviteCrew: true, onFinished: {}, onClose: {})
        .environmentObject(AppStore())
}
