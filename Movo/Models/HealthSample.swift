import Foundation

/// Mock health data for the pitch demo. In the full version this connects to Apple Health / Google Fit.
struct HealthSnapshot {
    let restingHeartRate: Int
    let heartRateSamples: [Int]
    let sleepHours: Double
    let deepSleepHours: Double
    let remSleepHours: Double
    let screenTimeHours: Double
    let screenTimeDeltaMinutes: Int
    let waterGlasses: Int
    let waterGoal: Int

    static let mock = HealthSnapshot(
        restingHeartRate: 68,
        heartRateSamples: [62, 65, 84, 70, 66],
        sleepHours: 7.17,
        deepSleepHours: 1.8,
        remSleepHours: 2.08,
        screenTimeHours: 4.37,
        screenTimeDeltaMinutes: -38,
        waterGlasses: 5,
        waterGoal: 8
    )

    var sleepLabel: String {
        let h = Int(sleepHours)
        let m = Int((sleepHours - Double(h)) * 60)
        return "\(h)h\(String(format: "%02d", m))"
    }

    var screenTimeLabel: String {
        let h = Int(screenTimeHours)
        let m = Int((screenTimeHours - Double(h)) * 60)
        return "\(h)h\(String(format: "%02d", m))"
    }
}
