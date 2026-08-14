import SwiftUI

struct WorkoutLogView: View {
    @EnvironmentObject var store: AppStore
    @State private var amounts: [Exercise: Int] = [:]
    @State private var justLogged: Exercise?

    var body: some View {
        ZStack {
            Color.movoBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("LOG A WORKOUT")
                        .font(.movoHeader(30))
                        .foregroundStyle(Color.movoTextPrimary)
                        .padding(.top, 24)

                    VStack(spacing: 14) {
                        ForEach(Exercise.allCases) { exercise in
                            ExerciseRow(
                                exercise: exercise,
                                amount: amounts[exercise, default: exercise.unit == .minutes ? 10 : 15],
                                justLogged: justLogged == exercise,
                                onAmountChange: { amounts[exercise] = $0 },
                                onLog: { amount in
                                    store.logWorkout(exercise: exercise, amount: amount)
                                    justLogged = exercise
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        if justLogged == exercise { justLogged = nil }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    if !store.workoutLog.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("RECENT")
                                .font(.movoMono(12, weight: .semibold))
                                .foregroundStyle(Color.movoTextSecondary)
                                .padding(.horizontal, 20)

                            VStack(spacing: 8) {
                                ForEach(store.workoutLog.prefix(6)) { entry in
                                    HStack {
                                        Image(systemName: entry.exercise.symbolName)
                                            .foregroundStyle(Color.movoSteel)
                                        Text("\(entry.amount) \(entry.exercise.displayName)")
                                            .font(.movoMono(13))
                                            .foregroundStyle(Color.movoTextPrimary)
                                        Spacer()
                                        Text("+\(entry.points)")
                                            .font(.movoMono(13, weight: .bold))
                                            .foregroundStyle(Color.movoVolt)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.movoPanel)
                                    .overlay(Rectangle().strokeBorder(Color.movoPanelBorder))
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }
}

private struct ExerciseRow: View {
    var exercise: Exercise
    var amount: Int
    var justLogged: Bool
    var onAmountChange: (Int) -> Void
    var onLog: (Int) -> Void

    var body: some View {
        BracketPanel(accent: justLogged ? .movoVolt : .movoSteel) {
            HStack(spacing: 14) {
                Image(systemName: exercise.symbolName)
                    .font(.system(size: 22))
                    .foregroundStyle(Color.movoSteel)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.displayName.uppercased())
                        .font(.movoMono(14, weight: .semibold))
                        .foregroundStyle(Color.movoTextPrimary)
                    Text("\(exercise.pointsPerUnit) pt / \(exercise.unit.shortLabel)")
                        .font(.movoMono(11))
                        .foregroundStyle(Color.movoTextSecondary)
                }

                Spacer()

                Stepper(value: Binding(get: { amount }, set: onAmountChange), in: 1...200) {
                    Text("\(amount) \(exercise.unit.shortLabel)")
                        .font(.movoMono(13, weight: .bold))
                        .foregroundStyle(Color.movoTextPrimary)
                        .frame(minWidth: 60)
                }
                .labelsHidden()
                .fixedSize()
            }

            Button {
                onLog(amount)
            } label: {
                Text(justLogged ? "LOGGED +\(exercise.points(for: amount))" : "LOG \(exercise.points(for: amount)) PTS")
                    .font(.movoMono(13, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(justLogged ? Color.movoVolt.opacity(0.3) : Color.movoVolt)
                    .foregroundStyle(Color.black)
            }
            .padding(.top, 12)
        }
    }
}

#Preview {
    WorkoutLogView().environmentObject(AppStore())
}
