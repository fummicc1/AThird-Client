import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapCard(sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty else {
            let alert = UIAlertController(title: "エラー", message: "ユーザー名を先に入力してください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let jokerNumber = sender.tag
        var me = Me(name: name, joker: jokerNumber, score: nil)
        if let scoredUnixDate = UserDefaults.standard.object(forKey: "scoredUnixDate") as? TimeInterval {
            let scoreValue = UserDefaults.standard.object(forKey: "scoreValue") as! Int
            me.score = Score(date: Date(timeIntervalSince1970: scoredUnixDate), value: scoreValue)
        }
        GameManager.manager.me = me
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
