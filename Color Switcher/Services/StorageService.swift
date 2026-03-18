import Foundation

final class StorageService {
    static let shared = StorageService()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let accessToken = "app_access_token"
        static let contentLink = "app_content_link"
        static let levelStats = "level_stats"
        static let settings = "app_settings"
        static let hasRequestedReview = "has_requested_review"
    }
    
    private init() {}
    
    var accessToken: String? {
        get { defaults.string(forKey: Keys.accessToken) }
        set { defaults.set(newValue, forKey: Keys.accessToken) }
    }
    
    var contentLink: String? {
        get { defaults.string(forKey: Keys.contentLink) }
        set { defaults.set(newValue, forKey: Keys.contentLink) }
    }
    
    var hasRequestedReview: Bool {
        get { defaults.bool(forKey: Keys.hasRequestedReview) }
        set { defaults.set(newValue, forKey: Keys.hasRequestedReview) }
    }
    
    func getLevelStats() -> [Int: LevelStats] {
        guard let data = defaults.data(forKey: Keys.levelStats),
              let stats = try? JSONDecoder().decode([Int: LevelStats].self, from: data) else {
            return [:]
        }
        return stats
    }
    
    func saveLevelStats(_ stats: [Int: LevelStats]) {
        if let data = try? JSONEncoder().encode(stats) {
            defaults.set(data, forKey: Keys.levelStats)
        }
    }
    
    func updateStatsForLevel(_ levelId: Int, score: Int, time: TimeInterval, completed: Bool) {
        var allStats = getLevelStats()
        var levelStats = allStats[levelId] ?? LevelStats(levelId: levelId)
        levelStats.updateWith(score: score, time: time, completed: completed)
        allStats[levelId] = levelStats
        saveLevelStats(allStats)
    }
    
    func getSettings() -> AppSettings {
        guard let data = defaults.data(forKey: Keys.settings),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .defaultSettings
        }
        return settings
    }
    
    func saveSettings(_ settings: AppSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: Keys.settings)
        }
    }
}
