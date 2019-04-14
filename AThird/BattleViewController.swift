import UIKit
import KituraKit
import KituraContracts

class BattleViewController: UIViewController {

    private let kitura = KituraKit(baseURL: "http://localhost:8080")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func selectJoker(me: Me) {
        kitura?.post("/aThird/selectJoker", data: me, respondWith: { (isCorrect: Bool?, requestError: Error?) -> () in
            
        })
    }
    
}
