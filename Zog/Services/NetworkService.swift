import Foundation
import SystemConfiguration
import Combine
import CoreWLAN

final class NetworkService: ObservableObject {
    @Published private(set) var isWiFiConnected: Bool = false
    @Published private(set) var ssid: String?
    @Published private(set) var signalBars: Int = 0

    private var timer: Timer?

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func refresh() {
        // Reachability via SystemConfiguration
        var zero = sockaddr_in()
        zero.sin_len = UInt8(MemoryLayout.size(ofValue: zero))
        zero.sin_family = sa_family_t(AF_INET)

        guard let reachability = withUnsafePointer(to: &zero, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            isWiFiConnected = false
            return
        }

        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        let reachable = flags.contains(.reachable) && !flags.contains(.connectionRequired)

        // Wi-Fi details via CoreWLAN when available
        if let interface = CWWiFiClient.shared().interface() {
            ssid = interface.ssid()
            isWiFiConnected = reachable && ssid != nil
            let rssi = interface.rssiValue()
            signalBars = bars(from: rssi)
        } else {
            isWiFiConnected = reachable
            signalBars = reachable ? 3 : 0
        }
    }

    private func bars(from rssi: Int) -> Int {
        switch rssi {
        case -55...0: return 3
        case -70 ..< -55: return 2
        case -85 ..< -70: return 1
        default: return 0
        }
    }
}
