import SwiftUI

struct HealthDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    private let snapshot = HealthSnapshot.mock

    var body: some View {
        ScrollView {
                VStack(spacing: 16) {
                    Text("Health")
                        .font(.movoDisplay(28))
                        .foregroundStyle(scheme.movoTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)

                    MovoBanner(icon: "heart.text.square", text: "Sample data. Connects to Apple Health / Google Fit in the full version.", tint: .movoAmber)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        heartRateCard.frame(height: 160)
                        sleepCard.frame(height: 160)
                        screenTimeCard.frame(height: 160)
                        waterCard.frame(height: 160)
                    }

                    weeklyCheckIn
                }
                .padding(.horizontal, MovoMetrics.screenPadding)
                .padding(.bottom, 32)
            }
            .background(scheme.movoBackground.ignoresSafeArea())
    }

    private var heartRateCard: some View {
        RoundedCard {
            SectionHeading(title: "Heart rate")
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(snapshot.restingHeartRate)")
                    .font(.movoDisplay(26))
                    .foregroundStyle(Color.movoAmber)
                Text("bpm")
                    .font(.movoBody(11))
                    .foregroundStyle(scheme.movoTextSecondary)
            }
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(snapshot.heartRateSamples.enumerated()), id: \.offset) { _, v in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.movoAmber.opacity(Double(v) / 100.0 + 0.3))
                        .frame(width: 8, height: CGFloat(v) * 0.5)
                }
            }
            .frame(height: 30, alignment: .bottom)
        }
    }

    private var sleepCard: some View {
        RoundedCard {
            SectionHeading(title: "Sleep")
            Text(snapshot.sleepLabel)
                .font(.movoDisplay(26))
                .foregroundStyle(Color.movoBlue)
            HStack(spacing: 3) {
                Capsule().fill(Color.movoBlue.opacity(0.4)).frame(width: 34, height: 8)
                Capsule().fill(Color.movoBlue).frame(width: 46, height: 8)
                Capsule().fill(Color.movoBlue.opacity(0.6)).frame(width: 20, height: 8)
            }
            Text("Deep \(String(format: "%.0fh%02d", snapshot.deepSleepHours, Int((snapshot.deepSleepHours.truncatingRemainder(dividingBy: 1)) * 60))) · REM \(String(format: "%.0fh%02d", snapshot.remSleepHours, Int((snapshot.remSleepHours.truncatingRemainder(dividingBy: 1)) * 60)))")
                .font(.movoBody(10))
                .foregroundStyle(scheme.movoTextSecondary)
        }
    }

    private var screenTimeCard: some View {
        RoundedCard {
            SectionHeading(title: "Screen time")
            Text(snapshot.screenTimeLabel)
                .font(.movoDisplay(26))
                .foregroundStyle(Color.movoPink)
            Text("\(snapshot.screenTimeDeltaMinutes) min vs last week")
                .font(.movoBody(10))
                .foregroundStyle(scheme.movoTextSecondary)
        }
    }

    private var waterCard: some View {
        RoundedCard {
            SectionHeading(title: "Water")
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(snapshot.waterGlasses)")
                    .font(.movoDisplay(26))
                    .foregroundStyle(Color.movoBlue)
                Text("/ \(snapshot.waterGoal)")
                    .font(.movoBody(12))
                    .foregroundStyle(scheme.movoTextSecondary)
            }
            HStack(spacing: 4) {
                ForEach(0..<snapshot.waterGoal, id: \.self) { i in
                    Image(systemName: "drop.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(i < snapshot.waterGlasses ? Color.movoBlue : scheme.movoSurfaceAlt)
                }
            }
        }
    }

    private var weeklyCheckIn: some View {
        RoundedCard {
            HStack(alignment: .top, spacing: 14) {
                CharacterPortrait(accent: store.character.accent.color, stage: store.character.stage, mood: store.mood, gear: store.character.gear(), targetHeight: 64)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly check-in")
                        .font(.movoBody(14, weight: .bold))
                        .foregroundStyle(scheme.movoTextPrimary)
                    Text("\(store.weeklySessionsCount) workout\(store.weeklySessionsCount == 1 ? "" : "s"), \(store.character.pointsToNextStage) pts to \(store.character.stage.next?.displayName ?? "Champion"). Sleep is your weak spot.")
                        .font(.movoBody(12))
                        .foregroundStyle(scheme.movoTextSecondary)
                }
            }
        }
    }
}

#Preview {
    HealthDashboardView().environmentObject(AppStore())
}
