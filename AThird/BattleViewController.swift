import UIKit
import Starscream

class BattleViewController: UIViewController {
    
    @IBOutlet var turnLabel: UILabel!
    @IBOutlet var opponentCard11: UIButton!
    @IBOutlet var opponentCard22: UIButton!
    @IBOutlet var opponentCard33: UIButton!
    
    var socket: WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        socket?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ResultViewController
        destination.isWin = sender as! Bool
        destination.socket = socket
    }
    
    @IBAction func didTapCard(sender: UIButton) {
        GameManager.shared.me?.selectedCardTag = sender.tag
        if [11, 22, 33].contains(sender.tag), GameManager.shared.me?.isAttacking == true {
            sendMyPrediction(selectCardTag: sender.tag, eventName: .selectCard)
        } else if [1, 2, 3].contains(sender.tag), GameManager.shared.me?.isAttacking == false {
            sendMyPrediction(selectCardTag: sender.tag, eventName: .temptationJoker)
        }
    }
    
    // 相手のジョーカーを決定！送信！
    func sendMyPrediction(selectCardTag: Int, eventName: WebSocketEventName) {
        let result = Result(answer: nil, selectTag: selectCardTag, webSocketEventName: eventName)
        if let data = try? JSONEncoder().encode(result) {
            socket?.write(data: data)
        }
    }
    
    func setLabelText(_ text: String) {
        turnLabel.text = text
    }
    
    func showOpponentChoice(result: Result) {
        if result.isCorrect {
            setLabelText("相手にジョーカーを引かれてしまいました。GameOverです。。。")
            GameManager.shared.me?.webSocketEventName = .opponent
            if let opponent = GameManager.shared.me, let data = try? JSONEncoder().encode(opponent) {
                socket?.write(data: data, completion: {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toResult", sender: false)
                    }
                })
            }
        } else {
            setLabelText("おめでとうございます！相手はジョーカーを引かずに、\(result.selectTag % 10)を引きました。チャンスです！")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.moveToNextTurn()
            }
        }
    }
    
    func showChosenResult(result: Result) {
        if result.isCorrect {
            setLabelText("お見事です！ジョーカーを無事に当てました！")
            GameManager.shared.me?.webSocketEventName = .opponent
            if let opponent = GameManager.shared.me, let data = try? JSONEncoder().encode(opponent) {
                socket?.write(data: data, completion: {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toResult", sender: true)
                    }
                })
            }
        } else {
            setLabelText("残念。ジョーカーを外してしまいました。。。")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.moveToNextTurn()
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

extension BattleViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "エラー", message: "通信が切断されました。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "戻る", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        if let opponent = try? JSONDecoder().decode(Opponent.self, from: data), opponent.webSocketEventName == .opponent {
            GameManager.shared.opponent = opponent
        } else if var result = try? JSONDecoder().decode(Result.self, from: data) {
            DispatchQueue.main.async {
                if result.webSocketEventName == .selectCard {
                    result.answer = GameManager.shared.me?.joker
                    result.webSocketEventName = .choiceResult
                    let data = try! JSONEncoder().encode(result)
                    self.socket?.write(data: data) {
                        self.showOpponentChoice(result: result)
                    }
                } else if result.webSocketEventName == .temptationJoker {
                    self.dummyMovement(tag: result.selectTag)
                } else if result.webSocketEventName == .choiceResult {
                    self.showChosenResult(result: result)
                }
            }
        }
    }
}
