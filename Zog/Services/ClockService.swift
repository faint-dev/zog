import Foundation
import Combine

@MainActor
final class ClockService: ObservableObject {
    @Published private(set) var dateText: String = ""
    @Published private(set) var timeText: String = ""
    @Published private(set) var combined: String = ""

    private var timer: Timer?

    /// `DateFormatter` is expensive to mutate; we own one per format key.
    private let dateFormatter: DateFormatter
    private let timeFormatter: DateFormatter

    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "dd/MM"
        self.dateFormatter = dateFormatter

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_GB")
        timeFormatter.dateFormat = "HH:mm"
        self.timeFormatter = timeFormatter
    }

    func start() {
        tick()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            // `Timer` callbacks land on the run loop they were scheduled on;
            // we attached to `.main`, so this is already main-thread, but
            // the explicit hop makes MainActor checking happy under Xcode 26.
            Task { @MainActor [weak self] in self?.tick() }
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let now = Date()
        let d = dateFormatter.string(from: now)
        let t = timeFormatter.string(from: now)
        if d != dateText { dateText = d }
        if t != timeText { timeText = t }
        // Matches reference clock island: `25/07 00:10`
        let combined = "\(d) \(t)"
        if combined != self.combined { self.combined = combined }
    }
}
