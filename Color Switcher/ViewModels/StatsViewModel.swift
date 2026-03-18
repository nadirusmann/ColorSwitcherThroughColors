import Foundation

struct LevelStatDisplay {
    let levelId: Int
    let levelName: String
    let highScore: Int
    let targetScore: Int
    let gamesPlayed: Int
    let wins: Int
    let losses: Int
    let winRate: Double
    let averageScore: String
    let bestTime: String
    let isCompleted: Bool
}

struct OverallStats {
    let totalGames: Int
    let totalWins: Int
    let totalLosses: Int
    let overallWinRate: Double
    let levelsCompleted: Int
    let totalLevels: Int
    let totalHighScore: Int
}

final class StatsViewModel {
    
    var statsData: [LevelStatDisplay] {
        let allStats = StorageService.shared.getLevelStats()
        return Level.allLevels.map { level in
            let stats = allStats[level.id]
            let avgScore = stats?.averageScore ?? 0
            let bestTime = stats?.bestTime
            
            var timeString = "-"
            if let time = bestTime {
                let minutes = Int(time) / 60
                let seconds = Int(time) % 60
                timeString = String(format: "%d:%02d", minutes, seconds)
            }
            
            let isCompleted = (stats?.wins ?? 0) > 0
            
            return LevelStatDisplay(
                levelId: level.id,
                levelName: level.name,
                highScore: stats?.highScore ?? 0,
                targetScore: level.ringCount,
                gamesPlayed: stats?.gamesPlayed ?? 0,
                wins: stats?.wins ?? 0,
                losses: stats?.losses ?? 0,
                winRate: stats?.winRate ?? 0,
                averageScore: String(format: "%.1f", avgScore),
                bestTime: timeString,
                isCompleted: isCompleted
            )
        }
    }
    
    var overallStats: OverallStats {
        let allStats = StorageService.shared.getLevelStats()
        let totalGames = allStats.values.reduce(0) { $0 + $1.gamesPlayed }
        let totalWins = allStats.values.reduce(0) { $0 + $1.wins }
        let totalLosses = allStats.values.reduce(0) { $0 + $1.losses }
        let winRate = totalGames > 0 ? Double(totalWins) / Double(totalGames) * 100 : 0
        let levelsCompleted = allStats.values.filter { $0.wins > 0 }.count
        let totalHighScore = allStats.values.reduce(0) { $0 + $1.highScore }
        
        return OverallStats(
            totalGames: totalGames,
            totalWins: totalWins,
            totalLosses: totalLosses,
            overallWinRate: winRate,
            levelsCompleted: levelsCompleted,
            totalLevels: Level.allLevels.count,
            totalHighScore: totalHighScore
        )
    }
}
