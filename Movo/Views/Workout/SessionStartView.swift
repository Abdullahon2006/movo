import SwiftUI

struct SessionStartView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    var onStart: (WorkoutSessionTemplate, Bool) -> Void
    var onClose: () -> Void

    @State private var category: SessionCategory = .holds
    @State private var selected: WorkoutSessionTemplate?
    @State private var inviteCrew: Bool = true

    private var templates: [WorkoutSessionTemplate] { SessionLibrary.templates(for: category) }

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        categoryPicker

                        VStack(spacing: 12) {
                            ForEach(templates) { template in
                                SessionTemplateCard(
                                    template: template,
                                    isSelected: selected?.id == template.id,
                                    action: { selected = template }
                                )
                            }
                        }

                        scoringPanel

                        RoundedCard {
                            Toggle(isOn: $inviteCrew) {
                                Text("Invite the crew to join live")
                                    .font(.movoBody(14, weight: .medium))
                                    .foregroundStyle(scheme.movoTextPrimary)
                            }
                            .tint(.movoLime)
                        }
                    }
                    .padding(.horizontal, MovoMetrics.screenPadding)
                    .padding(.bottom, 16)
                }

                MovoPillButton(
                    title: selected.map { "Start \($0.name)" } ?? "Pick a session",
                    accent: .movoLime,
                    isEnabled: selected != nil,
                    action: { if let selected { onStart(selected, inviteCrew) } }
                )
                .padding(.horizontal, MovoMetrics.screenPadding)
                .padding(.bottom, 20)
            }
        }
        .onChange(of: category) { _, _ in selected = templates.first }
        .onAppear { if selected == nil { selected = templates.first } }
    }

    private var header: some View {
        HStack {
            Text("Start a session")
                .font(.movoDisplay(20))
                .foregroundStyle(scheme.movoTextPrimary)
            Spacer()
            Button(action: onClose) {
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

    private var categoryPicker: some View {
        HStack(spacing: 8) {
            ForEach(SessionCategory.allCases) { cat in
                MovoChip(title: cat.displayName, isSelected: category == cat, accent: .movoLime) {
                    category = cat
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var scoringPanel: some View {
        RoundedCard {
            SectionHeading(title: "Time-based scoring")
            scoringRow(name: "Plank / hollow hold", rate: "3 pts / 10s")
            scoringRow(name: "Wall sit, squat hold", rate: "2.5 pts / 10s")
            scoringRow(name: "Stretch, mobility", rate: "1 pt / 10s")
        }
    }

    private func scoringRow(name: String, rate: String) -> some View {
        HStack {
            Text(name)
                .font(.movoBody(12))
                .foregroundStyle(scheme.movoTextSecondary)
            Spacer()
            Text(rate)
                .font(.movoBody(12, weight: .bold))
                .foregroundStyle(Color.movoLime)
        }
    }
}

private struct SessionTemplateCard: View {
    @Environment(\.colorScheme) private var scheme
    var template: WorkoutSessionTemplate
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedCard(borderColor: isSelected ? .movoLime : nil) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.name)
                            .font(.movoBody(15, weight: .semibold))
                            .foregroundStyle(scheme.movoTextPrimary)
                        Text(template.summary)
                            .font(.movoBody(11))
                            .foregroundStyle(scheme.movoTextSecondary)
                    }
                    Spacer()
                    Text("+\(template.estimatedPoints) pts")
                        .font(.movoBody(13, weight: .bold))
                        .foregroundStyle(Color.movoLime)
                }
                HStack(spacing: 4) {
                    ForEach(Array(template.moves.enumerated()), id: \.offset) { idx, _ in
                        Capsule()
                            .fill(idx == 0 && isSelected ? Color.movoLime : scheme.movoSurfaceAlt)
                            .frame(height: 5)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SessionStartView(onStart: { _, _ in }, onClose: {}).environmentObject(AppStore())
}
