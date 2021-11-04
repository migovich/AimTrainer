//
//  GameManager.swift
//  AimTrainer
//
//  Created by Myhovych on 04.11.2021.
//

import Foundation

final class GameManager {
    
    static func highscore() -> Int {
        return UserDefaults.standard.integer(forKey: "highScore")
    }
    
    static func setHighscore(_ highscore: Int) {
        UserDefaults.standard.set(highscore, forKey: "highScore")
    }
}
