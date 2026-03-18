import Foundation

struct AppSettings: Codable {
    var vibrationEnabled: Bool
    var soundEnabled: Bool
    
    static var defaultSettings: AppSettings {
        return AppSettings(vibrationEnabled: true, soundEnabled: true)
    }
}
