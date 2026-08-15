import SwiftUI

struct WorkoutLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    var initialExercise: Exercise = .pushUps
    var initialAmount: Double? = nil

    @State private var exercise: Exercise
    @State private var amount: Double
    @State private var postToFeed: Bool = true
    @State private var justLogged: Bool = false

    init(initialExercise: Exercise = .pushUps, initialAmount: Double? = nil) {
        self.initialExercise = initialExercise
        self.initialAmount = initialAmount
        _exercise = State(initialValue: initialExercise)
        _amount = State(initialValue: initialAmount ?? initialExercise.defaultAmount)
    }

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 20) {
                        exerciseGrid
                        amountStepper
                        pointsPreview

                        RoundedCard {
                            Toggle(isOn: $postToFeed) {
                                Text("Post a photo to the crew feed")
                                    .font(.movoBody(14, weight: .medium))
                                    .foregroundStyle(scheme.movoTextPrimary)
                            }
                            .tint(store.character.accent.color)
                        }
                    }
                    .padding(.horizontal, MovoMetrics.screenPadding)
                    .padding(.bottom, 16)
                }

                MovoPillButton(
                    title: justLogged ? "Logged +\(store.pointsForExercise(exercise, amount: amount)) pts" : "Log it",
                    accent: store.character.accent.color,
                    isEnabled: amount > 0,
                    action: logIt
                )
                .padding(.horizontal, MovoMetrics.screenPadding)
                .padding(.bottom, 20)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Log a workout")
                .font(.movoDisplay(20))
                .foregroundStyle(scheme.movoTextPrimary)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(scheme.movoTextSecondary)
                    .padding(8)
                    .background(Circle().fill(scheme.movoSurfaceAlt))
            }
        }
        .padding(.horizontal, MovoMetrics.screenPadding)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    private var exerciseGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Exercise.allCases) { ex in
                Button {
                    exercise = ex
                    amount = ex.defaultAmount
                    justLogged = false
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ex.displayName)
                            .font(.movoBody(14, weight: .semibold))
                            .foregroundStyle(exercise == ex ? Color.black.opacity(0.85) : scheme.movoTextPrimary)
                        Text(ex.weightLabel)
                            .font(.movoBody(11))
                            .foregroundStyle(exercise == ex ? Color.black.opacity(0.6) : scheme.movoTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous)
                            .fill(exercise == ex ? store.character.accent.color : scheme.movoSurface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous)
                            .strokeBorder(exercise == ex ? Color.clear : scheme.movoBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var amountStepper: some View {
        RoundedCard {
            SectionHeading(title: "How many")
            HStack {
                stepButton(symbol: "minus") {
                    amount = max(exercise.step, amount - exercise.step)
                    justLogged = false
                }

                Spacer()
                VStack(spacing: 2) {
                    Text(amountLabel)
                        .font(.movoDisplay(36))
                        .foregroundStyle(scheme.movoTextPrimary)
                    Text(exercise.kind == .dist ? "km" : (exercise.kind == .reps ? "reps" : "seconds"))
                        .font(.movoBody(12))
                        .foregroundStyle(scheme.movoTextSecondary)
                }
                Spacer()

                stepButton(symbol: "plus", filled: true) {
                    amount += exercise.step
                    justLogged = false
                }
            }
        }
    }

    private func stepButton(symbol: String, filled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(filled ? .black.opacity(0.85) : scheme.movoTextPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(filled ? store.character.accent.color : scheme.movoSurfaceAlt))
        }
    }

    private var amountLabel: String {
        exercise.kind == .dist ? String(format: "%.1f", amount) : "\(Int(amount))"
    }

    private var pointsPreview: some View {
        let pts = store.pointsForExercise(exercise, amount: amount)
        let willReachNext = store.character.totalPoints + pts >= (store.character.stage.next?.threshold ?? Int.max)
        return RoundedCard {
            HStack {
                Text("You'll earn")
                    .font(.movoBody(13))
                    .foregroundStyle(scheme.movoTextSecondary)
                Spacer()
                Text("+\(pts) pts")
                    .font(.movoDisplay(20))
                    .foregroundStyle(Color.movoLime)
            }
            Text("points = amount × weight × streak bonus × multiplier")
                .font(.movoBody(11))
                .foregroundStyle(scheme.movoTextSecondary)
            if willReachNext, let next = store.character.stage.next {
                Text("Enough to push \(store.character.name.isEmpty ? "your Movo" : store.character.name) to \(next.displayName).")
                    .font(.movoBody(12, weight: .semibold))
                    .foregroundStyle(Color.movoLime)
            }
        }
    }

    private func logIt() {
        _ = store.logWorkout(exercise: exercise, amount: amount, postToFeed: postToFeed)
        justLogged = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            dismiss()
        }
    }
}

#Preview {
    WorkoutLogView().environmentObject(AppStore())
}
