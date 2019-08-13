import Foundation

class Server {
    static let url: String = "ws://localhost:8080/connectwebsocket"
}

class GameManager {
    
    static let shared = GameManager()
    
    var me: Me?
    var opponent: Opponent?
}
