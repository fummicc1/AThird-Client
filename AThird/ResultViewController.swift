import UIKit

class ResultViewController: UIViewController {

    @IBOutlet var opponentJokerLabel: UILabel!
    @IBOutlet var myJokerLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    
    var isWin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isWin {
            resultLabel.text = "勝利！！"
        } else {
            resultLabel.text = "敗北.！"
        }
        myJokerLabel.text = "マイジョーカー\n\(GameManager.shared.me!.joker % 10)"
        opponentJokerLabel.text = "敵のジョーカー\n\(GameManager.shared.opponent!.joker % 10)"
    }
}
