import Foundation

final class GameViewModel {
    
    let level: Level
    private(set) var score: Int = 0
    private(set) var isGameOver: Bool = false
    private var startTime: Date?
    private var gameTime: TimeInterval = 0
    
    var onScoreChanged: ((Int) -> Void)?
    var onGameOver: ((Int, TimeInterval) -> Void)?
    
    init(level: Level) {
        self.level = level
    }
    
    func startGame() {
        score = 0
        isGameOver = false
        startTime = Date()
        onScoreChanged?(score)
    }
    
    func addScore() {
        guard !isGameOver else { return }
        score += 1
        onScoreChanged?(score)
        HapticService.shared.lightImpact()
    }
    
    func endGame(completed: Bool = false) {
        guard !isGameOver else { return }
        isGameOver = true
        
        if let start = startTime {
            gameTime = Date().timeIntervalSince(start)
        }
        
        StorageService.shared.updateStatsForLevel(level.id, score: score, time: gameTime, completed: completed)
        if completed {
            HapticService.shared.success()
        } else {
            HapticService.shared.error()
        }
        onGameOver?(score, gameTime)
    }
    
    func getAvailableColors() -> [GameColor] {
        return Array(GameColor.allCases.prefix(level.colorsAvailable))
    }
}
