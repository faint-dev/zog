import Foundation
import Combine

final class ClockService: ObservableObject {
    @Published private(set) var dateText: String = ""
    @Published private(set) var timeText: String = ""
    @Published private(set) var combined: String = ""

    private var timer: Timer?
    private let formatter = DateFormatter()

    func start() {
        formatter.locale = Locale(identifier: "en_GB")
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let now = Date()
        formatter.dateFormat = "dd/MM"
        dateText = formatter.string(from: now)
        formatter.dateFormat = "HH:mm"
        timeText = formatter.string(from: now)
        // Matches reference clock island: `25/07 00:10`
        combined = "\(dateText) \(timeText)"
    }
}
