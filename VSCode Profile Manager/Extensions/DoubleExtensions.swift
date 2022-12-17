import Foundation

extension Double {
    func quantityString() -> String {
        switch abs(self) {
        case ...1000: return "\(self)"
        case ...1_000_000: return "\(Int(self / 1000))K"
        default: return "\(Int(self / 1_000_000))M"
        }
    }

    func fixedString(_ n: UInt = 1) -> String {
        let fix = pow(10.0, Double(n))
        let rounded = (self * fix).rounded()
        return floor(self) == self ? "\(Int(self))" : "\(rounded / fix)"
    }
}
