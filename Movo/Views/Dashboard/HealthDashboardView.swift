import SwiftUI

struct HealthDashboardView: View {
    private let snapshot = HealthSnapshot.mock

    var body: some View {
        ZStack {
            Color.movoBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("HEALTH HUD")
                        .font(.movoHeader(30))
                        .foregroundStyle(Color.movoTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    VStack(spacing: 14) {
                        StatPanel(
                            icon: "heart.fill",
                            accent: .movoCoral,
                            label: "RESTING HEART RATE",
                            value: "\(snapshot.restingHeartRate)",
                            unit: "BPM"
                        )
                        StatPanel(
                            icon: "bed.double.fill",
                            accent: .movoSteel,
                            label: "SLEEP",
                            value: String(format: "%.1f", snapshot.sleepHours),
                            unit: "HRS"
                        )
                        StatPanel(
                            icon: "iphone",
                            accent: .movoVolt,
                            label: "SCREEN TIME",
                            value: String(format: "%.1f", snapshot.screenTimeHours),
                            unit: "HRS"
                        )
                    }
                    .padding(.horizontal, 20)

                    BracketPanel {
                        HStack(spacing: 10) {
                            Image(systemName: "applewatch")
                                .foregroundStyle(Color.movoTextSecondary)
                            Text("Sample data for the pitch — connects to Apple Health / wearables in the full version.")
                                .font(.movoMono(11))
                                .foregroundStyle(Color.movoTextSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

private struct StatPanel: View {
    var icon: String
    var accent: Color
    var label: String
    var value: String
    var unit: String

    var body: some View {
        BracketPanel(accent: accent) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(accent)
                    .frame(width: 36)

                Text(label)
                    .font(.movoMono(12, weight: .semibold))
                    .foregroundStyle(Color.movoTextSecondary)

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.movoMono(26, weight: .bold))
                        .foregroundStyle(Color.movoTextPrimary)
                    Text(unit)
                        .font(.movoMono(12, weight: .semibold))
                        .foregroundStyle(Color.movoTextSecondary)
                }
            }
        }
    }
}

#Preview {
    HealthDashboardView()
}
