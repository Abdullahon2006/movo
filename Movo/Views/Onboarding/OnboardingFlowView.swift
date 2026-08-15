import SwiftUI

/// Hosts the 3-step onboarding: experience level, sports + frequency, then the starting-point
/// recap. Answers are written to `store.onboarding` as the user progresses.
struct OnboardingFlowView: View {
    @EnvironmentObject var store: AppStore
    @State private var step: Int = 0

    var body: some View {
        ZStack {
            Group {
                switch step {
                case 0:
                    OnboardingExperienceView(step: step, onContinue: { withAnimation { step = 1 } })
                case 1:
                    OnboardingSportsView(step: step, onContinue: { withAnimation { step = 2 } })
                default:
                    OnboardingRecapView(step: step)
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)).combined(with: .opacity))
        }
    }
}

/// Three-segment progress indicator shown at the top of every onboarding step.
struct OnboardingProgressBar: View {
    var step: Int // 0...2
    var accent: Color = .movoLime
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? accent : scheme.movoSurfaceAlt)
                    .frame(height: 5)
            }
        }
    }
}

struct OnboardingScaffold<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    var step: Int
    var eyebrow: String
    var title: String
    var subtitle: String
    var buttonTitle: String
    var buttonEnabled: Bool = true
    var onContinue: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 18) {
                    OnboardingProgressBar(step: step)
                        .padding(.top, 18)

                    Text(eyebrow.uppercased())
                        .font(.movoBody(11, weight: .semibold))
                        .foregroundStyle(Color.movoLime)
                        .tracking(0.6)

                    Text(title)
                        .font(.movoDisplay(30))
                        .foregroundStyle(scheme.movoTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(.movoBody(14))
                        .foregroundStyle(scheme.movoTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, MovoMetrics.screenPadding)
                .padding(.bottom, 20)

                ScrollView {
                    content
                        .padding(.horizontal, MovoMetrics.screenPadding)
                        .padding(.bottom, 20)
                }

                MovoPillButton(title: buttonTitle, accent: .movoLime, isEnabled: buttonEnabled, action: onContinue)
                    .padding(.horizontal, MovoMetrics.screenPadding)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    OnboardingFlowView().environmentObject(AppStore())
}
