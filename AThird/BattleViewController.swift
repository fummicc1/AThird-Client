import UIKit
import Starscream

class BattleViewController: UIViewController, WebSocketDelegate {
    
    @IBOutlet var turnLabel: UILabel!
    
    @IBOutlet var opponentCard11: UIButton!
    @IBOutlet var opponentCard22: UIButton!
    @IBOutlet var opponentCard33: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var labelHeightConstraint: NSLayoutConstraint!
    
    var socket: WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket?.delegate = self
        if GameManager.shared.me!.isHost {
            turnLabel.text = "マイターン"
        }
        animateDescriptionLabel(willShow: true, message: "バトルが始まりました。頑張りましょう。")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateDescriptionLabel(willShow: false, message: nil)
    }
    
    @IBAction func didTapCard(sender: UIButton) {
        GameManager.shared.me?.selectedCardTag = sender.tag
        if [11, 22, 33].contains(sender.tag), turnLabel.text == "マイターン" {
            sendMyPrediction()
        } else if [1, 2, 3].contains(sender.tag), turnLabel.text == "相手のターン" {
            sendMyPrediction()
        }
    }
    
    // 相手のジョーカーを決定！送信！
    func sendMyPrediction() {
        guard let data = try? JSONEncoder().encode(GameManager.shared.me!) else {
            return
        }
        socket?.write(data: data)
    }
    
    // 対戦相手から送られてきたデータが正解なのか否かを送信。
    func opponentChoseResult(selectedTag: Int) {
        if selectedTag == GameManager.shared.me?.selectedCardTag {
            socket?.write(string: "You are correct.")
        } else {
            socket?.write(string: "You made a mistake.")
        }
    }
    
    func animateDescriptionLabel(willShow: Bool, message: String?) {
        if let message = message {
            descriptionLabel.text = message
        }
        descriptionLabel.layoutIfNeeded()
        if willShow {
            labelHeightConstraint.constant = 200
        } else {
            labelHeightConstraint.constant = 0
        }
        UIView.transition(with: descriptionLabel, duration: 3.0, options: .curveEaseIn, animations: {
            self.descriptionLabel.layoutIfNeeded()
        }, completion: nil)
    }
    
    func websocketDidConnect(socket: WebSocketClient) { }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "エラー", message: "通信が切断されました。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "戻る", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // ここは、カードを選んだ結果の判定をするのみ。
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if text == "You are correct." {
            GameManager.shared.me?.score?.value += 10
            DispatchQueue.main.async {
                self.showChosenResult(isWin: true)
            }
        } else if text == "You made a mistake." {
            DispatchQueue.main.async {
                self.showChosenResult(isWin: false)
            }
        }
    }
    
    func showChosenResult(isWin: Bool) {
        animateDescriptionLabel(willShow: true, message: isWin ? "お見事です！ジョーカーを無事に当てました！" : "残念。ジョーカーを外してしまいました。。。")
        animateDescriptionLabel(willShow: false, message: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.moveToNextTurn()
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        guard let opponent = try? JSONDecoder().decode(Opponent.self, from: data) else {
            return
        }
        GameManager.shared.opponent = opponent
        if let opponentSelectedTag = opponent.selectedCardTag, opponentSelectedTag == GameManager.shared.me?.joker {
            showChosenResult(isWin: true)
        } else if let opponentSelectedTag = opponent.selectedCardTag, opponentSelectedTag != GameManager.shared.me?.joker, [11, 22, 33].contains(opponentSelectedTag) {
            showChosenResult(isWin: false)
        } else if let opponentSelectedTag = opponent.selectedCardTag, [1, 2, 3].contains(opponentSelectedTag) {
            // ダミー動作を送信。受信者は攻撃ターン。
            DispatchQueue.main.async {
                self.dummyMovement(tag: opponentSelectedTag)
            }
        }
    }
    
    func dummyMovement(tag: Int) {
        UIView.animate(withDuration: 2.0, animations: {
            var target: UIButton
            if tag == 1 {
                target = self.opponentCard11
            } else if tag == 2 {
                target = self.opponentCard22
            } else if tag == 3 {
                target = self.opponentCard33
            } else {
                target = UIButton()
            }
            UIView.transition(with: target, duration: 1.0, options: [.transitionCurlUp, .autoreverse], animations: {
                target.isHidden = true
            }) { _ in
                target.isHidden = false
            }
        }, completion: nil)
    }
    
    func resetJoker() {
        GameManager.shared.me?.joker = 0
        GameManager.shared.me?.selectedCardTag = nil
        GameManager.shared.opponent?.joker = 0
        GameManager.shared.opponent?.selectedCardTag = nil
    }
    
    func moveToNextTurn() {
        resetJoker()
        animateDescriptionLabel(willShow: true, message: "次のターンに移りました。頑張ってください！")
        turnLabel.text = turnLabel.text == "マイターン" ? "相手のターン" : "マイターン"
        opponentCard11.setTitle(nil, for: .normal)
        opponentCard22.setTitle(nil, for: .normal)
        opponentCard33.setTitle(nil, for: .normal)
    }
}
