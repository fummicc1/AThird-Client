import UIKit
import KituraKit

class ViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!    
    @IBOutlet var aButton: UIButton!
    @IBOutlet var bButton: UIButton!
    @IBOutlet var cButton: UIButton!
    
    let kitura = KituraKit(baseURL: "http://localhost:8080")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapCard(sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty else {
            return
        }
        let score = UserDefaults.standard.integer(forKey: "score")
        let jokerNumber = sender.tag
        let me = Me(name: name, joker: jokerNumber, score: score)
        GameManager.manager.me = me
        kitura?.post("/aThird/setupUser", data: me, respondWith: { [weak self] (me: Me?, error: Error?) -> () in
            if let error = error {
                fatalError("\(error)")
            }
            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: "toBattle", sender: nil)
            }
        })
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
