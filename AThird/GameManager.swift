import Foundation
import KituraKit

class GameManager {
    static let manager = GameManager()
    private init() {}
    
    var me: Me?
    var opponent: Opponent?
 
    func setMyJoker(joker: Int) {
        me?.joker = joker
    }
    
    func setOpponentJoker(joker: Int) {
        opponent?.joker = joker
    }
}
