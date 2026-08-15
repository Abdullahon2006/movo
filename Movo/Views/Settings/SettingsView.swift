import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 20) {
                        themeSection
                        accentSection
                        languageSection
                        nudgesSection
                        unitsSection

                        Text("movo 0.1 · hackathon build")
                            .font(.movoBody(11))
                            .foregroundStyle(scheme.movoTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, MovoMetrics.screenPadding)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").foregroundStyle(scheme.movoTextPrimary)
            }
            Spacer()
            Text("Settings")
                .font(.movoDisplay(18))
                .foregroundStyle(scheme.movoTextPrimary)
            Spacer()
            Color.clear.frame(width: 20, height: 20)
        }
        .padding(.horizontal, MovoMetrics.screenPadding)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "Theme")
            HStack(spacing: 10) {
                ThemeCard(mode: .dark, isSelected: store.settings.theme == .dark) { store.settings.theme = .dark }
                ThemeCard(mode: .light, isSelected: store.settings.theme == .light) { store.settings.theme = .light }
                ThemeCard(mode: .auto, isSelected: store.settings.theme == .auto) { store.settings.theme = .auto }
            }
        }
    }

    private var accentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "Accent — tints the app and your Movo")
            HStack(spacing: 14) {
                ForEach(AccentOption.allCases) { option in
                    Circle()
                        .fill(option.color)
                        .frame(width: 38, height: 38)
                        .overlay(Circle().strokeBorder(scheme.movoTextPrimary, lineWidth: store.settings.accent == option ? 3 : 0))
                        .overlay(Circle().strokeBorder(scheme.movoBorder, lineWidth: 1))
                        .onTapGesture { store.updateAccent(option) }
                }
                Circle()
                    .fill(scheme.movoSurfaceAlt)
                    .frame(width: 38, height: 38)
                    .overlay(Image(systemName: "lock.fill").font(.system(size: 12)).foregroundStyle(scheme.movoTextSecondary))
            }
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "Language")
            RoundedCard {
                ForEach(Array(AppLanguage.allCases.enumerated()), id: \.element) { idx, lang in
                    VStack(spacing: 0) {
                        if idx > 0 { Divider().overlay(scheme.movoBorder) }
                        HStack {
                            Text(lang.displayName)
                                .font(.movoBody(14, weight: .medium))
                                .foregroundStyle(scheme.movoTextPrimary)
                            if lang.isRTL {
                                Text("RTL")
                                    .font(.movoBody(9, weight: .bold))
                                    .foregroundStyle(scheme.movoTextSecondary)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Capsule().fill(scheme.movoSurfaceAlt))
                            }
                            Spacer()
                            if store.settings.language == lang {
                                Image(systemName: "checkmark").foregroundStyle(Color.movoLime)
                            }
                        }
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                        .onTapGesture { store.settings.language = lang }
                    }
                }
                Divider().overlay(scheme.movoBorder)
                Text("More languages...")
                    .font(.movoBody(13))
                    .foregroundStyle(scheme.movoTextSecondary)
                    .padding(.top, 10)
            }
        }
    }

    private var nudgesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "Nudges")
            RoundedCard {
                NudgeToggle(title: "Movo talks to you", subtitle: "Pep talks, guilt trips, milestones", isOn: $store.settings.nudges.movoTalks)
                Divider().overlay(scheme.movoBorder)
                NudgeToggle(title: "Daily crew drop", subtitle: "Random time, 2-minute window", isOn: $store.settings.nudges.dailyCrewDrop)
                Divider().overlay(scheme.movoBorder)
                NudgeToggle(title: "Water reminders", subtitle: "Every 2 hours, 9:00–21:00", isOn: $store.settings.nudges.waterReminders)
            }
        }
    }

    private var unitsSection: some View {
        HStack {
            Text("Units")
                .font(.movoBody(14, weight: .semibold))
                .foregroundStyle(scheme.movoTextPrimary)
            Spacer()
            HStack(spacing: 4) {
                ForEach(UnitSystem.allCases) { unit in
                    Text(unit.displayName)
                        .font(.movoBody(12, weight: .semibold))
                        .foregroundStyle(store.settings.units == unit ? .black.opacity(0.85) : scheme.movoTextSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(store.settings.units == unit ? Color.movoLime : Color.clear))
                        .onTapGesture { store.settings.units = unit }
                }
            }
            .background(Capsule().fill(scheme.movoSurfaceAlt))
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).fill(scheme.movoSurface))
    }
}

private struct ThemeCard: View {
    @Environment(\.colorScheme) private var scheme
    var mode: ThemeMode
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(mode == .light ? Color.white : (mode == .auto ? Color.gray : Color.movoCanvas))
                    .frame(height: 50)
                    .overlay(
                        VStack(alignment: .leading, spacing: 3) {
                            Capsule().fill(Color.movoLime).frame(width: 20, height: 4)
                            Capsule().fill((mode == .light ? Color.black : Color.white).opacity(0.3)).frame(width: 28, height: 4)
                        }
                        .padding(8), alignment: .topLeading
                    )
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.black.opacity(0.08)))
                Text(mode.displayName)
                    .font(.movoBody(12, weight: .semibold))
                    .foregroundStyle(scheme.movoTextPrimary)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).fill(scheme.movoSurface))
            .overlay(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).strokeBorder(isSelected ? Color.movoLime : scheme.movoBorder, lineWidth: isSelected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }
}

private struct NudgeToggle: View {
    @Environment(\.colorScheme) private var scheme
    var title: String
    var subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.movoBody(14, weight: .semibold)).foregroundStyle(scheme.movoTextPrimary)
                Text(subtitle).font(.movoBody(11)).foregroundStyle(scheme.movoTextSecondary)
            }
        }
        .tint(.movoLime)
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView().environmentObject(AppStore())
}
