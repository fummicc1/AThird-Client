import UIKit
import Starscream

class ViewController: UIViewController, WebSocketDelegate, UITextFieldDelegate {
    
    @IBOutlet var nameTextField: UITextField!
    
    var socket: WebSocket = WebSocket(url: URL(string: Server.url)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBattle" {
            let destination = segue.destination as! BattleViewController
            let socket = sender as! WebSocket
            destination.socket = socket
        }
    }
    
    @IBAction func didTapCard(sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty else {
            let alert = UIAlertController(title: "エラー", message: "ユーザー名を先に入力してください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let jokerNumber = sender.tag
        var me = Me(name: name, joker: jokerNumber, score: nil, selectedCardTag: nil, isHost: false)
        if let scoredUnixDate = UserDefaults.standard.object(forKey: "scoredUnixDate") as? TimeInterval {
            let scoreValue = UserDefaults.standard.object(forKey: "scoreValue") as! Int
            me.score = Score(date: Date(timeIntervalSince1970: scoredUnixDate), value: scoreValue)
        }
        GameManager.shared.me = me
        
        guard let data = try? JSONEncoder().encode(me) else {
            return
        }
        socket.connect()
        socket.write(data: data)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func websocketDidConnect(socket: WebSocketClient) { }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "エラー", message: "通信が切断されました。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "戻る", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if text == "Opponent Found!!" {
            DispatchQueue.main.async {
                self.moveToBattle()
            }
        } else if text == "Opponent Found!! You are Host!" {
            GameManager.shared.me?.isHost = true
            DispatchQueue.main.async {
                self.moveToBattle()
            }
        } else if text == "Looking For Opponent!!" {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "🔄", message: "対戦相手を探しています。", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        guard let opponent = try? JSONDecoder().decode(Opponent.self, from: data) else {
            return
        }
        GameManager.shared.opponent = opponent
        
    }
    
    func moveToBattle() {
        if presentedViewController is UIAlertController {
            dismiss(animated: true, completion: nil)
        }
        performSegue(withIdentifier: "toBattle", sender: socket)
    }
}
