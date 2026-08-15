import SwiftUI

/// Which accessories are visually attached to the rig. Defaults to the stage's natural
/// unlocks, but callers (wardrobe) can override to preview a custom loadout.
struct GearSet {
    var headband = false
    var tankTop = false
    var goldBand = false
    var crown = false
    var cape = false
    var runners = false

    static func forStage(_ stage: Stage) -> GearSet {
        GearSet(
            headband: stage.hasHeadband,
            tankTop: stage.hasTankTop,
            goldBand: stage.hasGoldBand,
            crown: stage.hasCrown,
            cape: stage.hasCape,
            runners: stage >= .athlete
        )
    }
}

/// The Movo character, rendered from layered shapes. Same body kit at every stage — mass and
/// gear increase with progression; eyes and mouth swap with mood.
struct CharacterShapeView: View {
    var accent: Color
    var stage: Stage
    var mood: Mood = .happy
    var gear: GearSet? = nil

    private var resolvedGear: GearSet { gear ?? .forStage(stage) }
    private var isSulking: Bool { mood == .sulking }
    private var bodyColor: Color { isSulking ? accent.desaturated() : accent }

    var body: some View {
        Group {
            if stage == .egg {
                eggBody
            } else {
                fullBody
            }
        }
        .frame(width: 200, height: 232)
        .scaleEffect(stage.massScale)
        // Bake the scale into the reported layout size too, so containers that size or clip
        // around this view (cards, clipShape) account for the visually larger rendered stages
        // instead of cropping the overflow.
        .frame(width: 200 * stage.massScale, height: 232 * stage.massScale)
        .animation(.spring(response: 0.6, dampingFraction: 0.78), value: stage)
        .animation(.easeInOut(duration: 0.4), value: mood)
    }

    private var eggBody: some View {
        ZStack {
            EggShape()
                .fill(
                    LinearGradient(colors: [bodyColor.lighter(by: 0.2), bodyColor.darker(by: 0.08)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 128, height: 160)
            crackMarks
        }
    }

    private var crackMarks: some View {
        VStack(spacing: 10) {
            Path { p in
                p.move(to: CGPoint(x: 0, y: 6))
                p.addLine(to: CGPoint(x: 20, y: 0))
                p.addLine(to: CGPoint(x: 40, y: 8))
            }
            .stroke(bodyColor.lighter(by: 0.35), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            .frame(width: 40, height: 12)

            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 28, y: 4))
            }
            .stroke(bodyColor.lighter(by: 0.35), style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .frame(width: 28, height: 8)
            .offset(x: 14)
        }
    }

    private var fullBody: some View {
        ZStack {
            if resolvedGear.cape {
                CapeShape()
                    .fill(bodyColor.darker(by: 0.15))
                    .frame(width: 96, height: 120)
                    .offset(y: 26)
            }

            // Legs
            HStack(spacing: 14) {
                shoe
                shoe
            }
            .offset(y: 84)

            // Arms
            HStack {
                Capsule().fill(bodyColor).frame(width: 30, height: 64)
                    .rotationEffect(.degrees(-14), anchor: .top)
                Spacer()
                Capsule().fill(bodyColor).frame(width: 30, height: 64)
                    .rotationEffect(.degrees(14), anchor: .top)
            }
            .frame(width: 168)
            .offset(y: 8)

            // Torso
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(colors: [bodyColor.lighter(by: 0.12), bodyColor.darker(by: 0.05)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 108, height: 96)
                .offset(y: 24)

            if resolvedGear.tankTop {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(bodyColor.darker(by: 0.32))
                    .frame(width: 44, height: 66)
                    .offset(y: 20)
            }

            if resolvedGear.goldBand {
                Capsule()
                    .fill(Color(hex: "#E8B84B"))
                    .frame(width: 100, height: 12)
                    .offset(y: 56)
            }

            // Head
            Circle()
                .fill(
                    LinearGradient(colors: [bodyColor.lighter(by: 0.18), bodyColor.darker(by: 0.04)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 118, height: 118)
                .offset(y: -58)
                .overlay(FaceView(mood: mood).offset(y: -58))

            if resolvedGear.headband {
                Capsule()
                    .fill(Color.movoAmber)
                    .frame(width: 108, height: 16)
                    .offset(y: -104)
            }

            if resolvedGear.crown {
                CrownShape()
                    .fill(Color(hex: "#E8B84B"))
                    .frame(width: 60, height: 34)
                    .offset(y: -132)
            }
        }
    }

    private var shoe: some View {
        Capsule()
            .fill(Color(hex: "#F3F4F0"))
            .frame(width: 34, height: 20)
            .overlay(Capsule().strokeBorder(Color.black.opacity(0.08), lineWidth: 1))
            .overlay {
                if resolvedGear.runners {
                    Capsule().fill(bodyColor).frame(width: 20, height: 5)
                }
            }
    }
}

/// A fixed-height presentation wrapper around `CharacterShapeView`. Stages render at different
/// natural sizes (mass increases with progression), so this scales uniformly against the
/// tallest possible stage — bigger stages fill the box, smaller stages sit smaller inside it —
/// instead of letting any stage clip against a caller's fixed frame.
struct CharacterPortrait: View {
    var accent: Color
    var stage: Stage
    var mood: Mood = .happy
    var gear: GearSet? = nil
    var targetHeight: CGFloat = 200

    private let maxNaturalHeight: CGFloat = 232 * 1.45

    var body: some View {
        let k = targetHeight / maxNaturalHeight
        CharacterShapeView(accent: accent, stage: stage, mood: mood, gear: gear)
            .scaleEffect(k)
            .frame(width: 200 * stage.massScale * k, height: 232 * stage.massScale * k)
    }
}

private struct FaceView: View {
    var mood: Mood

    var body: some View {
        ZStack {
            eyes
            mouth
            extras
        }
    }

    @ViewBuilder private var eyes: some View {
        switch mood {
        case .happy, .firedUp, .annoyed:
            HStack(spacing: 22) {
                eyeDot
                eyeDot
            }
            .offset(y: -4)
        case .wrecked:
            HStack(spacing: 22) {
                sleepyEye
                sleepyEye
            }
            .offset(y: -4)
        case .sulking:
            HStack(spacing: 22) {
                sadEye
                sadEye
            }
            .offset(y: -2)
        }
    }

    private var eyeDot: some View {
        Circle().fill(Color.black.opacity(0.85)).frame(width: 11, height: 11)
    }

    private var sleepyEye: some View {
        Capsule().fill(Color.black.opacity(0.85)).frame(width: 13, height: 4)
    }

    private var sadEye: some View {
        Circle().fill(Color.black.opacity(0.7)).frame(width: 8, height: 8)
    }

    @ViewBuilder private var mouth: some View {
        switch mood {
        case .happy:
            SmileShape(curveUp: true).stroke(Color.black.opacity(0.85), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 26, height: 12).offset(y: 16)
        case .firedUp:
            Ellipse().fill(Color.black.opacity(0.85)).frame(width: 16, height: 12).offset(y: 16)
        case .wrecked:
            Ellipse().fill(Color.black.opacity(0.8)).frame(width: 20, height: 14).offset(y: 18)
        case .annoyed:
            Capsule().fill(Color.black.opacity(0.85)).frame(width: 22, height: 4).offset(y: 16)
        case .sulking:
            SmileShape(curveUp: false).stroke(Color.black.opacity(0.7), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .frame(width: 22, height: 10).offset(y: 18)
        }
    }

    @ViewBuilder private var extras: some View {
        switch mood {
        case .firedUp:
            TearDrop().fill(Color.movoBlue).frame(width: 8, height: 12).offset(x: 40, y: -14)
            eyebrowBar.offset(y: -18)
        case .wrecked:
            TearDrop().fill(Color.movoBlue).frame(width: 7, height: 10).offset(x: -38, y: -12)
            TearDrop().fill(Color.movoBlue).frame(width: 7, height: 10).offset(x: 38, y: -12)
        case .annoyed:
            eyebrowBar.offset(y: -16)
        case .sulking:
            TearDrop().fill(Color.movoBlue).frame(width: 7, height: 11).offset(x: -20, y: 6)
        case .happy:
            EmptyView()
        }
    }

    private var eyebrowBar: some View {
        HStack(spacing: 14) {
            Capsule().fill(Color(hex: "#E2472B")).frame(width: 16, height: 4).rotationEffect(.degrees(-14))
            Capsule().fill(Color(hex: "#E2472B")).frame(width: 16, height: 4).rotationEffect(.degrees(14))
        }
    }
}

private struct SmileShape: Shape {
    var curveUp: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: curveUp ? 0 : rect.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: curveUp ? 0 : rect.height),
            control: CGPoint(x: rect.width / 2, y: curveUp ? rect.height : 0)
        )
        return path
    }
}

private struct TearDrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.6), control: CGPoint(x: rect.maxX, y: rect.height * 0.15))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.height * 0.6), radius: rect.width / 2, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: 0), control: CGPoint(x: rect.minX, y: rect.height * 0.15))
        return path
    }
}

private struct CapeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.15))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.82))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.9, y: rect.height * 0.15))
        path.closeSubpath()
        return path
    }
}

private struct CrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.7))
        path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.7))
        path.addLine(to: CGPoint(x: w, y: h * 0.45))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}

extension Color {
    /// Drains saturation toward gray — used for the sulking mood.
    func desaturated() -> Color {
        let uic = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uic.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: s * 0.28, brightness: b * 0.92, opacity: a)
    }
}

#Preview {
    ZStack {
        Color.movoCanvas.ignoresSafeArea()
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                ForEach(Stage.allCases, id: \.self) { s in
                    CharacterShapeView(accent: .movoLime, stage: s, mood: .happy)
                        .frame(width: 70, height: 90)
                        .scaleEffect(0.4)
                }
            }
            HStack(spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { m in
                    CharacterShapeView(accent: .movoLime, stage: .rookie, mood: m)
                        .scaleEffect(0.4)
                        .frame(width: 70, height: 90)
                }
            }
        }
    }
}
