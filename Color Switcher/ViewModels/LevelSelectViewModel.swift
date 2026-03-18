import Foundation

final class LevelSelectViewModel {
    
    let levels: [Level] = Level.allLevels
    
    func getStatsForLevel(_ levelId: Int) -> LevelStats? {
        return StorageService.shared.getLevelStats()[levelId]
    }
    
    func isLevelUnlocked(_ level: Level) -> Bool {
        if level.id == 1 { return true }
        let previousLevelId = level.id - 1
        if let stats = getStatsForLevel(previousLevelId) {
            return stats.highScore >= 5
        }
        return false
    }
}
