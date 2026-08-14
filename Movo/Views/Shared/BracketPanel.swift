import SwiftUI

/// HUD-style viewfinder corner brackets drawn at the edges of a panel.
struct BracketCorners: View {
    var color: Color = .movoVolt
    var length: CGFloat = 18
    var thickness: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Path { path in
                // Top-left
                path.move(to: CGPoint(x: 0, y: length))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: length, y: 0))

                // Top-right
                path.move(to: CGPoint(x: w - length, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: length))

                // Bottom-right
                path.move(to: CGPoint(x: w, y: h - length))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: w - length, y: h))

                // Bottom-left
                path.move(to: CGPoint(x: length, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 0, y: h - length))
            }
            .stroke(color, style: StrokeStyle(lineWidth: thickness, lineCap: .square))
        }
        .allowsHitTesting(false)
    }
}

/// A dark HUD panel with bracket corners, used as the standard container across Movo.
struct BracketPanel<Content: View>: View {
    var accent: Color = .movoVolt
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .background(Color.movoPanel)
        .overlay(
            Rectangle()
                .strokeBorder(Color.movoPanelBorder, lineWidth: 1)
        )
        .overlay(BracketCorners(color: accent))
    }
}
