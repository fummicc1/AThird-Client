import Foundation

class Server {
    static let url: String = "ws://localhost:8080/battle"
}

class GameManager {
    
    static let shared = GameManager()
    
    var battleViewController: BattleViewController?
    
    var me: Me?
    var opponent: Opponent?
}
