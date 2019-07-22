import Foundation

struct Me: Codable {
    var name: String
    var joker: Int
    var selectedCardTag: Int?
    var isHost: Bool
    var isAttacking: Bool
    var webSocketEventName: WebSocketEventName
}

struct Opponent: Codable {
    var name: String
    var joker: Int
    var selectedCardTag: Int?
    var isAttacking: Bool
    var webSocketEventName: WebSocketEventName
}

struct Result: Codable {
    var answer: Int?
    var selectTag: Int
    var isCorrect: Bool {
        return answer == selectTag
    }
    var webSocketEventName: WebSocketEventName
}

enum WebSocketEventName: String, Codable {
    case selectCard
    case choiceResult
    case opponent
    case temptationJoker
    case connect
    case disConnect
    case none
}
