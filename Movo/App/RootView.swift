import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        if store.hasCreatedCharacter {
            MainTabView()
        } else {
            CharacterCreatorView()
        }
    }
}

private struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.movoPanel)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = UIColor(Color.movoVolt)
    }

    var body: some View {
        TabView {
            CharacterHomeView()
                .tabItem { Label("Character", systemImage: "person.fill") }

            WorkoutLogView()
                .tabItem { Label("Log", systemImage: "plus.circle.fill") }

            CrewFeedView()
                .tabItem { Label("Feed", systemImage: "bolt.fill") }

            HealthDashboardView()
                .tabItem { Label("Health", systemImage: "heart.fill") }
        }
        .tint(Color.movoVolt)
    }
}

#Preview {
    RootView().environmentObject(AppStore())
}
