import Foundation

struct Me: Codable {
    var name: String
    var joker: Int
    var selectedCardTag: Int?
    var isHost: Bool
    var isAttacking: Bool
}

struct Opponent: Codable {
    var name: String
    var joker: Int
    var selectedCardTag: Int?
    var isAttacking: Bool
}

struct Result: Codable {
    var answer: Int
    var selectTag: Int
    var isCorrect: Bool {
        return answer == selectTag
    }
}
