//
//  ViewController.swift
//  AThird
//
//  Created by Fumiya Tanaka on 2019/03/24.
//  Copyright © 2019 Fumiya Tanaka. All rights reserved.
//

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
        GameManager.manager.me = UserModel.Me(name: name, joker: jokerNumber, score: score)
        guard let meData = try? JSONEncoder().encode(GameManager.manager.me) else {
            return
        }
        kitura?.post("/aThird/setUser", data: meData) { (opponent: UserModel.Opponent?, error: Error?) -> Void in
            guard let opponent = opponent else {
                return
            }
            GameManager.manager.opponent = opponent
        }
        performSegue(withIdentifier: "toBattle", sender: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
