import Foundation

struct Me: Codable {
    var name: String
    var joker: Int
    var score: Score?
    var selectedCardTag: Int?
    var isHost: Bool
}

struct Opponent: Codable {
    var name: String
    var joker: Int
    var score: Score?
    var selectedCardTag: Int?
}

struct Score: Codable {
    var date: Date
    var value: Int
}
