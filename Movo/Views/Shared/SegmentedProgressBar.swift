import SwiftUI

/// Segmented block progress bar with a scoreboard feel, instead of a smooth continuous fill.
struct SegmentedProgressBar: View {
    var progress: Double // 0...1
    var segments: Int = 12
    var filledColor: Color = .movoVolt
    var emptyColor: Color = .movoPanelBorder
    var height: CGFloat = 14

    var body: some View {
        let filledCount = Int((progress.clamped(to: 0...1) * Double(segments)).rounded(.down))
        HStack(spacing: 3) {
            ForEach(0..<segments, id: \.self) { index in
                Rectangle()
                    .fill(index < filledCount ? filledColor : emptyColor)
            }
        }
        .frame(height: height)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
