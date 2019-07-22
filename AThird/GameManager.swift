import Foundation
import Starscream

class Server {
    static let url: String = "ws://localhost:8080/socket"
}

class GameManager {
    
    static let shared = GameManager()
    
    var me: Me?
    var opponent: Opponent?
}
