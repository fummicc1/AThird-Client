import Foundation

class Server {
    static let url: String = "ws://localhost:8080/battle/"
}

class GameManager {
    
    static let shared = GameManager()
    
    var me: Me?
    var opponent: Opponent?
 
    func setMyJoker(joker: Int) {
        me?.joker = joker
    }
    
    func setOpponentJoker(joker: Int) {
        opponent?.joker = joker
    }
}
