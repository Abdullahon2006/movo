import Foundation

/// Mock health data for the pitch demo. In the full version this connects to Apple Health / wearables.
struct HealthSnapshot {
    let restingHeartRate: Int
    let sleepHours: Double
    let screenTimeHours: Double

    static let mock = HealthSnapshot(restingHeartRate: 64, sleepHours: 7.2, screenTimeHours: 3.4)
}
