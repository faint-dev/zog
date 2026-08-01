import Foundation
import IOKit.ps
import Combine

@MainActor
final class BatteryService: ObservableObject {
    @Published private(set) var percentage: Int = 100
    @Published private(set) var isCharging: Bool = false
    @Published private(set) var isPresent: Bool = true

    private var timer: Timer?

    func start() {
        refresh()
        let timer = Timer(timeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.refresh() }
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
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
            if isPresent { isPresent = false }
            return
        }

        if !isPresent { isPresent = true }

        let newPercentage = info[kIOPSCurrentCapacityKey] as? Int ?? 100
        if newPercentage != percentage { percentage = newPercentage }

        let state = info[kIOPSPowerSourceStateKey] as? String
        let newCharging = state == kIOPSACPowerValue
            || (info[kIOPSIsChargingKey] as? Bool == true)
        if newCharging != isCharging { isCharging = newCharging }
    }
}
