import SwiftUI

/// The character rendered from layered shapes. Arms and torso scale up with `growthScale`
/// so muscle growth is visible as points grow. Layering is easy to extend with new shapes.
struct CharacterShapeView: View {
    var bodyColor: Color
    var outfitColor: Color
    var stage: Stage
    var growthScale: Double

    private var torsoWidth: CGFloat { 66 * growthScale }
    private var torsoHeight: CGFloat { 92 }
    private var armWidth: CGFloat { 24 * growthScale }
    private var armHeight: CGFloat { 70 * growthScale }
    private var legWidth: CGFloat { 26 }
    private var legHeight: CGFloat { 80 }
    private var headDiameter: CGFloat { 58 }

    var body: some View {
        ZStack {
            if stage.hasCape {
                Cape(color: .movoCoral)
                    .offset(y: -6)
            }

            // Legs
            HStack(spacing: 10) {
                Capsule().fill(outfitColor).frame(width: legWidth, height: legHeight)
                Capsule().fill(outfitColor).frame(width: legWidth, height: legHeight)
            }
            .offset(y: torsoHeight / 2 + legHeight / 2 - 6)

            // Torso
            RoundedRectangle(cornerRadius: 18)
                .fill(bodyColor)
                .frame(width: torsoWidth, height: torsoHeight)

            // Arms
            HStack {
                Capsule().fill(bodyColor).frame(width: armWidth, height: armHeight)
                    .rotationEffect(.degrees(-8))
                Spacer()
                Capsule().fill(bodyColor).frame(width: armWidth, height: armHeight)
                    .rotationEffect(.degrees(8))
            }
            .frame(width: torsoWidth + armWidth * 1.9)
            .offset(y: -6)

            // Head
            Circle()
                .fill(bodyColor)
                .frame(width: headDiameter, height: headDiameter)
                .overlay(Face())
                .offset(y: -(torsoHeight / 2 + headDiameter / 2) + 4)

            if stage.hasHeadband {
                Headband(color: .movoVolt)
                    .offset(y: -(torsoHeight / 2 + headDiameter / 2) + 4 - headDiameter / 2 + 14)
            }
        }
        .frame(width: 220, height: 260)
        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: growthScale)
    }
}

private struct Face: View {
    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(Color.black.opacity(0.85)).frame(width: 6, height: 6)
            Circle().fill(Color.black.opacity(0.85)).frame(width: 6, height: 6)
        }
        .offset(y: 2)
    }
}

private struct Headband: View {
    var color: Color
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 62, height: 10)
    }
}

private struct Cape: View {
    var color: Color
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: -30, y: -40))
            path.addLine(to: CGPoint(x: 30, y: -40))
            path.addLine(to: CGPoint(x: 44, y: 90))
            path.addLine(to: CGPoint(x: 0, y: 70))
            path.addLine(to: CGPoint(x: -44, y: 90))
            path.closeSubpath()
        }
        .fill(color)
        .offset(y: 20)
    }
}

#Preview {
    ZStack {
        Color.movoBackground.ignoresSafeArea()
        CharacterShapeView(bodyColor: .movoSteel, outfitColor: .movoCoral, stage: .legend, growthScale: 1.5)
    }
}
