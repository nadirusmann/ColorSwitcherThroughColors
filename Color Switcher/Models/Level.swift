import Foundation

struct Level: Codable {
    let id: Int
    let name: String
    let ringSpeed: Double
    let ballSpeed: Double
    let ringCount: Int
    let colorsAvailable: Int
    
    static let allLevels: [Level] = [
        Level(id: 1, name: "Beginner", ringSpeed: 1.0, ballSpeed: 150, ringCount: 10, colorsAvailable: 2),
        Level(id: 2, name: "Easy", ringSpeed: 1.2, ballSpeed: 170, ringCount: 15, colorsAvailable: 2),
        Level(id: 3, name: "Normal", ringSpeed: 1.5, ballSpeed: 190, ringCount: 20, colorsAvailable: 3),
        Level(id: 4, name: "Medium", ringSpeed: 1.8, ballSpeed: 210, ringCount: 25, colorsAvailable: 3),
        Level(id: 5, name: "Hard", ringSpeed: 2.0, ballSpeed: 230, ringCount: 30, colorsAvailable: 4),
        Level(id: 6, name: "Expert", ringSpeed: 2.3, ballSpeed: 250, ringCount: 35, colorsAvailable: 4),
        Level(id: 7, name: "Master", ringSpeed: 2.6, ballSpeed: 270, ringCount: 40, colorsAvailable: 4),
        Level(id: 8, name: "Insane", ringSpeed: 3.0, ballSpeed: 300, ringCount: 50, colorsAvailable: 4)
    ]
}
