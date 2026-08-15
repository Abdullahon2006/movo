import SwiftUI

// MARK: - Card

/// The standard rounded card container used across every screen.
struct RoundedCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    var padding: CGFloat = 18
    var borderColor: Color? = nil
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: MovoMetrics.cardRadius, style: .continuous)
                .fill(scheme.movoSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: MovoMetrics.cardRadius, style: .continuous)
                .strokeBorder(borderColor ?? scheme.movoBorder, lineWidth: borderColor != nil ? 2 : 1)
        )
        .shadow(color: scheme.movoShadow, radius: 12, y: 6)
    }
}

// MARK: - Buttons

struct MovoPillButton: View {
    @Environment(\.colorScheme) private var scheme
    var title: String
    var accent: Color
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.movoBody(16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .foregroundStyle(Color.black.opacity(isEnabled ? 0.88 : 0.4))
        .background(
            Capsule().fill(isEnabled ? accent : scheme.movoSurfaceAlt)
        )
        .disabled(!isEnabled)
    }
}

struct MovoGhostButton: View {
    @Environment(\.colorScheme) private var scheme
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.movoBody(14, weight: .semibold))
                .foregroundStyle(scheme.movoTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
    }
}

// MARK: - Chips

struct MovoChip: View {
    @Environment(\.colorScheme) private var scheme
    var title: String
    var isSelected: Bool
    var accent: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.movoBody(13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.black.opacity(0.85) : scheme.movoTextPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(isSelected ? accent : scheme.movoSurfaceAlt)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress

struct MovoProgressBar: View {
    var progress: Double // 0...1
    var accent: Color
    var height: CGFloat = 10
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(scheme.movoSurfaceAlt)
                Capsule()
                    .fill(accent)
                    .frame(width: max(height, geo.size.width * progress.clamped(to: 0...1)))
            }
        }
        .frame(height: height)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: progress)
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Stat tile

struct StatTile: View {
    @Environment(\.colorScheme) private var scheme
    var label: String
    var value: String
    var valueColor: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.movoBody(10, weight: .semibold))
                .foregroundStyle(scheme.movoTextSecondary)
                .tracking(0.4)
            Text(value)
                .font(.movoDisplay(20))
                .foregroundStyle(valueColor ?? scheme.movoTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Avatar

struct AvatarBubble: View {
    var name: String
    var colorHex: String
    var size: CGFloat = 40

    var body: some View {
        Circle()
            .fill(Color(hex: colorHex))
            .frame(width: size, height: size)
            .overlay(
                Text(String(name.prefix(1)).uppercased())
                    .font(.movoDisplay(size * 0.42))
                    .foregroundStyle(.black.opacity(0.75))
            )
    }
}

// MARK: - Section heading

struct SectionHeading: View {
    @Environment(\.colorScheme) private var scheme
    var title: String
    var body: some View {
        Text(title.uppercased())
            .font(.movoBody(11, weight: .bold))
            .tracking(0.6)
            .foregroundStyle(scheme.movoTextSecondary)
    }
}

// MARK: - Banner

struct MovoBanner: View {
    @Environment(\.colorScheme) private var scheme
    var icon: String
    var text: String
    var tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(text)
                .font(.movoBody(12, weight: .medium))
                .foregroundStyle(scheme.movoTextPrimary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous)
                .fill(tint.opacity(0.14))
        )
    }
}

// MARK: - Logo mark

/// Vector rendition of the final Movo icon — a rounded lime square with a centered black egg
/// and minimal crack marks. Used in-app wherever the wordmark/icon appears.
struct MovoEggMark: View {
    var accent: Color = .movoLime
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accent.lighter(by: 0.25), accent.darker(by: 0.12)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
            EggShape()
                .fill(Color.black)
                .frame(width: size * 0.46, height: size * 0.58)
            VStack(spacing: size * 0.05) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: size * 0.1, y: -size * 0.015))
                    path.addLine(to: CGPoint(x: size * 0.16, y: 0.01))
                }
                .stroke(accent, style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
                .frame(width: size * 0.16, height: size * 0.02)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: size * 0.12, y: 0))
                }
                .stroke(accent, style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
                .frame(width: size * 0.12, height: size * 0.02)
                .offset(x: size * 0.03)
            }
        }
        .frame(width: size, height: size)
    }
}

struct EggShape: Shape {
    func path(in rect: CGRect) -> Path {
        var points: [CGPoint] = []
        let cx = rect.midX, cy = rect.midY
        let rx = rect.width / 2, ry = rect.height / 2
        let n = 120
        for i in 0...n {
            let t = Double(i) / Double(n)
            let theta = t * 2 * .pi
            let sy = sin(theta)
            let sx = cos(theta)
            let squeeze = sy < 0 ? (1.0 - 0.22 * (-sy)) : (1.0 + 0.06 * sy)
            let x = cx + rx * sx * squeeze
            let y = cy + ry * sy
            points.append(CGPoint(x: x, y: y))
        }
        var path = Path()
        path.addLines(points)
        path.closeSubpath()
        return path
    }
}

struct MovoWordmark: View {
    @Environment(\.colorScheme) private var scheme
    var accent: Color = .movoLime
    var body: some View {
        HStack(spacing: 8) {
            MovoEggMark(accent: accent, size: 28)
            Text("movo")
                .font(.movoDisplay(20))
                .foregroundStyle(scheme.movoTextPrimary)
        }
    }
}

// MARK: - Streak badge

struct StreakBadge: View {
    var days: Int
    var lost: Bool
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(lost ? scheme.movoTextSecondary : Color.movoAmber)
                .frame(width: 7, height: 7)
            Text(lost ? "streak lost" : "\(days) days")
                .font(.movoBody(12, weight: .semibold))
                .foregroundStyle(scheme.movoTextPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Capsule().fill(scheme.movoSurfaceAlt))
    }
}
