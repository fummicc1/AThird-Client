//
//  GameManager.swift
//  AThird
//
//  Created by Fumiya Tanaka on 2019/03/25.
//  Copyright © 2019 Fumiya Tanaka. All rights reserved.
//

import Foundation
import KituraKit

class GameManager {
    static let manager = GameManager()
    private init() {}
    
    var me: UserModel.Me?
    var opponent: UserModel.Opponent?
 
    func setMyJoker(joker: Int) {
        me?.joker = joker
    }
    
    func setOpponentJoker(joker: Int) {
        opponent?.joker = joker
    }
    
    
}
