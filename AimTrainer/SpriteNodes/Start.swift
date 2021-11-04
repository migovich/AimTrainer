//
//  Start.swift
//  AimTrainer
//
//  Created by Myhovych on 04.11.2021.
//

import SpriteKit

final class Start: SKSpriteNode {
    
    static func populate(at point: CGPoint) -> Start {
        let start = Start(imageNamed: "start")
        let screen = UIScreen.main.bounds
        start.size = CGSize(width: screen.width / 4, height:  screen.height / 8)
        start.position = point
        start.name = "startNode"
        return start
    }
}
