import Foundation

final class SettingsViewModel {
    
    private var settings: AppSettings
    
    var vibrationEnabled: Bool {
        get { settings.vibrationEnabled }
        set {
            settings.vibrationEnabled = newValue
            saveSettings()
        }
    }
    
    var soundEnabled: Bool {
        get { settings.soundEnabled }
        set {
            settings.soundEnabled = newValue
            saveSettings()
        }
    }
    
    init() {
        settings = StorageService.shared.getSettings()
    }
    
    private func saveSettings() {
        StorageService.shared.saveSettings(settings)
    }
    
    func resetProgress() {
        StorageService.shared.saveLevelStats([:])
    }
}
