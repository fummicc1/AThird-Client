import UIKit
import Starscream

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var jokerCandidateButtonArray: [UIButton]!
    
    var socket = WebSocket(url: URL(string: Server.url)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        socket.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for button in jokerCandidateButtonArray {
            button.layer.cornerRadius = button.frame.height / 2
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBattle" {
            let destination = segue.destination as! BattleViewController
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
        let me = Me(name: name, joker: jokerNumber, selectedCardTag: nil, isHost: false, isAttacking: false ,webSocketEventName: .none)
        GameManager.shared.me = me
        socket.connect()
        let alert = UIAlertController(title: "🔄", message: "対戦相手を探しています。", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func moveToBattle() {
        if presentedViewController is UIAlertController {
            dismiss(animated: true, completion: nil)
        }
        performSegue(withIdentifier: "toBattle", sender: socket)
    }
}

extension ViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        if let me = GameManager.shared.me, let data = try? JSONEncoder().encode(me) {
            socket.write(data: data)
        }
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        DispatchQueue.main.async {
            if self.presentedViewController is UIAlertController {
                self.dismiss(animated: true, completion: {
                    let alert = UIAlertController(title: "エラー", message: "通信が切断されました。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "戻る", style: .default, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                let alert = UIAlertController(title: "エラー", message: "通信が切断されました。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "戻る", style: .default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        if let opponent = try? JSONDecoder().decode(Opponent.self, from: data) {
            GameManager.shared.opponent = opponent
            DispatchQueue.main.async {
                self.moveToBattle()
            }
        }
    }
}
