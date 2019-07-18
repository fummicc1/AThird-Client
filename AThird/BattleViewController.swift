import UIKit
import Starscream

class BattleViewController: UIViewController, WebSocketDelegate {
    
    @IBOutlet var turnLabel: UILabel!
    
    @IBOutlet var opponentCard11: UIButton!
    @IBOutlet var opponentCard22: UIButton!
    @IBOutlet var opponentCard33: UIButton!
    
    var socket: WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GameManager.shared.battleViewController = self
        socket?.delegate = self
        setLabelText("バトルが始まりました。頑張りましょう。")
        if GameManager.shared.me!.isHost {
            GameManager.shared.me?.isAttacking = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.setLabelText("マイターン")
            }
        } else {
            GameManager.shared.me?.isAttacking = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.setLabelText("相手のターン")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GameManager.shared.battleViewController = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ResultViewController
        destination.isWin = sender as! Bool
    }
    
    @IBAction func didTapCard(sender: UIButton) {
        GameManager.shared.me?.selectedCardTag = sender.tag
        if [11, 22, 33].contains(sender.tag), GameManager.shared.me?.isAttacking == true {
            sendMyPrediction()
        } else if [1, 2, 3].contains(sender.tag), GameManager.shared.me?.isAttacking == false {
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
    
    func setLabelText(_ text: String) {
        turnLabel.text = text
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
    }
    
    func showOpponentChoice(position: Int) {
        if position == GameManager.shared.me?.joker {
            setLabelText("相手にジョーカーを引かれてしまいました。GameOverです。。。")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.performSegue(withIdentifier: "toResult", sender: false)
            }
        } else {
            setLabelText("おめでとうございます！相手はジョーカーを引かずに、\(position % 10)を引きました。チャンスです！")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.moveToNextTurn()
            }
        }
    }
    
    func showChosenResult(result: Bool) {
        if result {
            setLabelText("お見事です！ジョーカーを無事に当てました！")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.performSegue(withIdentifier: "toResult", sender: true)
            }
        } else {
            setLabelText("残念。ジョーカーを外してしまいました。。。")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.moveToNextTurn()
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        if let opponent = try? JSONDecoder().decode(Opponent.self, from: data) {
            GameManager.shared.opponent = opponent
            if let opponentSelectedTag = opponent.selectedCardTag, opponentSelectedTag == GameManager.shared.me?.joker {
                // 相手が攻撃をして、正解した場合
                let resultData = try! JSONEncoder().encode(Result(answer: opponentSelectedTag, selectTag: opponentSelectedTag))
                socket.write(data: resultData)
                DispatchQueue.main.async {
                    self.showOpponentChoice(position: opponentSelectedTag)
                }
            } else if let opponentSelectedTag = opponent.selectedCardTag, opponentSelectedTag != GameManager.shared.me?.joker, [11, 22, 33].contains(opponentSelectedTag) {
                // 相手が攻撃をして、外した場合 (自分は受け。)
                let resultData = try! JSONEncoder().encode(Result(answer: GameManager.shared.me!.joker, selectTag: opponentSelectedTag))
                socket.write(data: resultData)
                DispatchQueue.main.async {
                    self.showOpponentChoice(position: opponentSelectedTag)
                }
            } else if let opponentSelectedTag = opponent.selectedCardTag, [1, 2, 3].contains(opponentSelectedTag) {
                // ダミー動作を送信。受信者は攻撃ターン。
                DispatchQueue.main.async {
                    self.dummyMovement(tag: opponentSelectedTag)
                }
            }
        } else if let result = try? JSONDecoder().decode(Result.self, from: data) {
            DispatchQueue.main.async {
                self.showChosenResult(result: result.isCorrect)
            }
        }
    }
    
    func dummyMovement(tag: Int) {
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
        target.setTitle("J", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            UIView.transition(with: target, duration: 1.0, options: [.transitionCurlUp, .autoreverse], animations: {
                target.isHidden = true
            }) { _ in
                target.isHidden = false
                target.setTitle("\(tag % 10)", for: .normal)
            }
        })
    }
    
    func resetJoker() {
        GameManager.shared.me?.selectedCardTag = nil
        GameManager.shared.opponent?.selectedCardTag = nil
    }
    
    func moveToNextTurn() {
        resetJoker()
        GameManager.shared.me?.isAttacking.toggle()
        setLabelText("次のターンに移りました。頑張ってください！")
        DispatchQueue.main.async {
            self.setLabelText(GameManager.shared.me?.isAttacking == true ? "マイターン" : "相手のターン")
        }
        opponentCard11.setTitle("1", for: .normal)
        opponentCard22.setTitle("2", for: .normal)
        opponentCard33.setTitle("3", for: .normal)
    }
}
