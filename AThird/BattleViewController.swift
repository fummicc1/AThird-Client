import UIKit
import Starscream

class BattleViewController: UIViewController, WebSocketDelegate {
    
    var socket: WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket?.delegate = self
    }
    
    private func selectJoker(me: Me) {
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
