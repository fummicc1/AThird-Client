import Foundation

struct Me: Codable {
    var name: String
    var joker: Int
    var score: Score?
}

struct Opponent: Codable {
    var name: String
    var joker: Int
    var score: Score?
}

struct Score: Codable {
    var date: Date
    var value: Int
}
