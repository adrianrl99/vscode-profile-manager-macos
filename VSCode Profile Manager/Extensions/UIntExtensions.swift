import Foundation

extension UInt {
    func humanizedByteString() -> String {
        let divider: Double = 1024
        let n = Double(self)

        switch n {
        case ...divider: return "\(self) B"
        case ...pow(divider, 2): return "\(round(n / 1024 * 100) / 100) KB"
        case ...pow(divider, 3): return "\(round(n / pow(1024, 2) * 100) / 100) MB"
        default: return "\(round(n / pow(1024, 3) * 100) / 100) GB"
        }
    }
}
