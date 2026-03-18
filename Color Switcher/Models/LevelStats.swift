import Foundation

struct LevelStats: Codable {
    var levelId: Int
    var highScore: Int
    var gamesPlayed: Int
    var totalScore: Int
    var bestTime: TimeInterval?
    var wins: Int
    var losses: Int
    
    var averageScore: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(totalScore) / Double(gamesPlayed)
    }
    
    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(wins) / Double(gamesPlayed) * 100
    }
    
    init(levelId: Int) {
        self.levelId = levelId
        self.highScore = 0
        self.gamesPlayed = 0
        self.totalScore = 0
        self.bestTime = nil
        self.wins = 0
        self.losses = 0
    }
    
    mutating func updateWith(score: Int, time: TimeInterval, completed: Bool) {
        gamesPlayed += 1
        totalScore += score
        if completed {
            wins += 1
        } else {
            losses += 1
        }
        if score > highScore {
            highScore = score
        }
        if let currentBest = bestTime {
            if time < currentBest {
                bestTime = time
            }
        } else {
            bestTime = time
        }
    }
}
