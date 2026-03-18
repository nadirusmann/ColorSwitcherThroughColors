import Foundation

final class MainMenuViewModel {
    
    var totalHighScore: Int {
        let stats = StorageService.shared.getLevelStats()
        return stats.values.reduce(0) { $0 + $1.highScore }
    }
    
    var totalGamesPlayed: Int {
        let stats = StorageService.shared.getLevelStats()
        return stats.values.reduce(0) { $0 + $1.gamesPlayed }
    }
}
