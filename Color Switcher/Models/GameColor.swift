import UIKit

enum GameColor: Int, CaseIterable {
    case red = 0
    case blue = 1
    case green = 2
    case yellow = 3
    
    var uiColor: UIColor {
        switch self {
        case .red: return UIColor(red: 0.95, green: 0.26, blue: 0.21, alpha: 1.0)
        case .blue: return UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1.0)
        case .green: return UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0)
        case .yellow: return UIColor(red: 1.0, green: 0.76, blue: 0.03, alpha: 1.0)
        }
    }
    
    var name: String {
        switch self {
        case .red: return "Red"
        case .blue: return "Blue"
        case .green: return "Green"
        case .yellow: return "Yellow"
        }
    }
    
    static func random() -> GameColor {
        return GameColor.allCases.randomElement() ?? .red
    }
    
    func next() -> GameColor {
        let allCases = GameColor.allCases
        let currentIndex = self.rawValue
        let nextIndex = (currentIndex + 1) % allCases.count
        return allCases[nextIndex]
    }
}
