import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var systemScheme

    var body: some View {
        Group {
            if !store.hasCompletedOnboarding {
                OnboardingFlowView()
            } else if !store.hasCreatedCharacter {
                CharacterCreatorView()
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(store.settings.theme.resolvedScheme(system: systemScheme))
        .tint(store.character.accent.color)
        .animation(.easeInOut(duration: 0.3), value: store.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.3), value: store.hasCreatedCharacter)
    }
}

private struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    @State private var tab: MovoTab = .movo

    var body: some View {
        Group {
            switch tab {
            case .movo: CharacterHomeView()
            case .crew: CrewFeedView()
            case .health: HealthDashboardView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // A real layout inset (not an overlay) so every tab's ScrollView content naturally
        // stops above the tab bar instead of being able to scroll underneath it.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MovoTabBar(selected: $tab, accent: store.character.accent.color)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(item: $store.workoutSheetPrefill) { prefill in
            WorkoutLogView(initialExercise: prefill.exercise, initialAmount: prefill.amount)
                .environmentObject(store)
        }
        .sheet(isPresented: $store.isSessionFlowPresented) {
            SessionFlowContainer().environmentObject(store)
        }
        .overlay {
            if let event = store.levelUpEvent {
                LevelUpModalView(event: event, onDismiss: { store.levelUpEvent = nil })
                    .environmentObject(store)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.levelUpEvent)
    }
}

private enum MovoTab {
    case movo, crew, health
}

private struct MovoTabBar: View {
    @Binding var selected: MovoTab
    var accent: Color
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.movo, label: "Movo") { shape in
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(shape)
                    .frame(width: 16, height: 16)
            }
            tabButton(.crew, label: "Crew") { shape in
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(shape, lineWidth: 2)
                    .frame(width: 16, height: 16)
            }
            tabButton(.health, label: "Health") { shape in
                Circle()
                    .strokeBorder(shape, lineWidth: 2)
                    .frame(width: 16, height: 16)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            scheme.movoBackground
                .overlay(Rectangle().fill(scheme.movoBorder).frame(height: 1), alignment: .top)
        )
    }

    private func tabButton<Shape: View>(_ value: MovoTab, label: String, @ViewBuilder icon: @escaping (AnyShapeStyle) -> Shape) -> some View {
        let isSelected = selected == value
        return Button {
            selected = value
        } label: {
            VStack(spacing: 4) {
                icon(AnyShapeStyle(isSelected ? accent : scheme.movoTextSecondary))
                Text(label)
                    .font(.movoBody(10, weight: .semibold))
                    .foregroundStyle(isSelected ? accent : scheme.movoTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RootView().environmentObject(AppStore())
}
