import UIKit
import Starscream

class ResultViewController: UIViewController {
    
    @IBOutlet var opponentJokerLabel: UILabel!
    @IBOutlet var myJokerLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    
    var isWin: Bool = false
    var socket: WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        socket?.delegate = self
        displayResult()
    }
    
    func displayResult() {
        if isWin {
            resultLabel.text = "勝利！！"
        } else {
            resultLabel.text = "敗北.！"
        }
        myJokerLabel.text = "マイジョーカー\n\(GameManager.shared.me!.joker % 10)"
        opponentJokerLabel.text = "敵のジョーカー\n\(GameManager.shared.opponent!.joker % 10)"
    }
    
    @IBAction func retry() {
        GameManager.shared.me = nil
        GameManager.shared.opponent = nil
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ResultViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
        if let opponent = try? JSONDecoder().decode(Opponent.self, from: data) {
            GameManager.shared.opponent = opponent
            if opponent.webSocketEventName == .opponent {
                DispatchQueue.main.async {
                    self.displayResult()
                }
            }
        } else if let result = try? JSONDecoder().decode(Result.self, from: data) {
            if result.webSocketEventName == .selectCard {
                
            } else if result.webSocketEventName == .choiceResult {
                
            }
        }
    }
}
