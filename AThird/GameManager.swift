import Foundation

class Server {
    static let url: String = "wss://7b54a928.ngrok.io/battle"
}

class GameManager {
    
    static let shared = GameManager()
    
    var me: Me?
    var opponent: Opponent? 
}
