import SwiftUI

struct CharacterCreatorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme

    @State private var name: String = ""
    @State private var accent: AccentOption = .lime

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meet your Movo")
                            .font(.movoDisplay(30))
                            .foregroundStyle(scheme.movoTextPrimary)
                        Text("It starts as an egg. You decide what it becomes.")
                            .font(.movoBody(14))
                            .foregroundStyle(scheme.movoTextSecondary)
                    }
                    .padding(.top, 24)

                    RoundedCard {
                        HStack {
                            Spacer()
                            EggShape()
                                .fill(
                                    LinearGradient(colors: [accent.color.lighter(by: 0.2), accent.color.darker(by: 0.08)],
                                                   startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 130, height: 164)
                                .overlay(alignment: .center) {
                                    VStack(spacing: 10) {
                                        Rectangle().fill(accent.color.lighter(by: 0.4)).frame(width: 40, height: 5)
                                        Rectangle().fill(accent.color.lighter(by: 0.4)).frame(width: 26, height: 5).offset(x: 12)
                                    }
                                }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeading(title: "Name")
                        TextField("", text: $name, prompt: Text("e.g. Bibo").foregroundStyle(scheme.movoTextSecondary))
                            .font(.movoBody(17, weight: .semibold))
                            .foregroundStyle(scheme.movoTextPrimary)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).fill(scheme.movoSurface))
                            .overlay(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).strokeBorder(Color.movoLime, lineWidth: 2))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeading(title: "Color")
                        HStack(spacing: 14) {
                            ForEach(AccentOption.allCases) { option in
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle().strokeBorder(scheme.movoTextPrimary, lineWidth: accent == option ? 3 : 0)
                                    )
                                    .overlay(
                                        Circle().strokeBorder(scheme.movoBorder, lineWidth: 1)
                                    )
                                    .onTapGesture { accent = option }
                            }
                        }
                    }

                    MovoPillButton(
                        title: name.trimmingCharacters(in: .whitespaces).isEmpty ? "Hatch your Movo" : "Hatch \(name.trimmingCharacters(in: .whitespaces))",
                        accent: .movoLime,
                        isEnabled: canCreate,
                        action: {
                            store.createCharacter(name: name.trimmingCharacters(in: .whitespaces), accent: accent)
                        }
                    )
                    .padding(.top, 8)

                    Text("No account. Your crew is everyone on this demo.")
                        .font(.movoBody(11))
                        .foregroundStyle(scheme.movoTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, MovoMetrics.screenPadding)
                .padding(.bottom, 32)
            }
        }
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

#Preview {
    CharacterCreatorView().environmentObject(AppStore())
}
