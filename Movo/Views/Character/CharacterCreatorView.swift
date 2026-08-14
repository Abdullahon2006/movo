import SwiftUI

struct CharacterCreatorView: View {
    @EnvironmentObject var store: AppStore

    @State private var name: String = ""
    @State private var bodyColorHex: String = "#3DDC97"
    @State private var outfitColorHex: String = "#FF6B5E"

    private let bodyColorOptions = ["#3DDC97", "#5B8DEF", "#C6FF00", "#FF6B5E", "#E8E8EC"]
    private let outfitColorOptions = ["#FF6B5E", "#C6FF00", "#5B8DEF", "#1A1A1E", "#E8E8EC"]

    var body: some View {
        ZStack {
            Color.movoBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("BUILD YOUR MOVO")
                        .font(.movoHeader(34))
                        .foregroundStyle(Color.movoVolt)
                        .padding(.top, 32)

                    CharacterShapeView(
                        bodyColor: Color(hex: bodyColorHex),
                        outfitColor: Color(hex: outfitColorHex),
                        stage: .rookie,
                        growthScale: 1.0
                    )
                    .frame(height: 240)

                    BracketPanel {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("NAME")
                                    .font(.movoMono(12, weight: .semibold))
                                    .foregroundStyle(Color.movoTextSecondary)
                                TextField("", text: $name, prompt: Text("e.g. Blaze").foregroundStyle(Color.movoTextSecondary))
                                    .font(.movoMono(18))
                                    .foregroundStyle(Color.movoTextPrimary)
                                    .padding(10)
                                    .background(Color.movoBackground)
                                    .overlay(Rectangle().strokeBorder(Color.movoPanelBorder))
                            }

                            ColorSwatchPicker(title: "BODY COLOR", options: bodyColorOptions, selection: $bodyColorHex)
                            ColorSwatchPicker(title: "OUTFIT COLOR", options: outfitColorOptions, selection: $outfitColorHex)
                        }
                    }
                    .padding(.horizontal, 20)

                    Button {
                        store.createCharacter(name: name.trimmingCharacters(in: .whitespaces), bodyColorHex: bodyColorHex, outfitColorHex: outfitColorHex)
                    } label: {
                        Text("ENTER THE GYM")
                            .font(.movoHeader(20))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(canCreate ? Color.movoVolt : Color.movoPanelBorder)
                            .foregroundStyle(Color.black)
                    }
                    .disabled(!canCreate)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

private struct ColorSwatchPicker: View {
    var title: String
    var options: [String]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.movoMono(12, weight: .semibold))
                .foregroundStyle(Color.movoTextSecondary)
            HStack(spacing: 12) {
                ForEach(options, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle().strokeBorder(Color.movoVolt, lineWidth: selection == hex ? 3 : 0)
                        )
                        .onTapGesture { selection = hex }
                }
            }
        }
    }
}

#Preview {
    CharacterCreatorView().environmentObject(AppStore())
}
