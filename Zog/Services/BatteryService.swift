import Foundation
import IOKit.ps
import Combine

final class BatteryService: ObservableObject {
    @Published private(set) var percentage: Int = 100
    @Published private(set) var isCharging: Bool = false
    @Published private(set) var isPresent: Bool = true

    private var timer: Timer?

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func refresh() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let first = sources.first,
              let info = IOPSGetPowerSourceDescription(snapshot, first)?.takeUnretainedValue() as? [String: Any]
        else {
            isPresent = false
            return
        }

        isPresent = true
        percentage = info[kIOPSCurrentCapacityKey] as? Int ?? 100
        let state = info[kIOPSPowerSourceStateKey] as? String
        isCharging = state == kIOPSACPowerValue
            || (info[kIOPSIsChargingKey] as? Bool == true)
    }
}
