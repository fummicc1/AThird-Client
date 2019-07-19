import Foundation

class Server {
    static let url: String = "https://athird-swift.herokuapp.com/"
}

class GameManager {
    
    static let shared = GameManager()
    
    var me: Me?
    var opponent: Opponent?
}
