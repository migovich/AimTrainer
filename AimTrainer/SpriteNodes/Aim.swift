//
//  Aim.swift
//  AimTrainer
//
//  Created by Myhovych on 04.11.2021.
//

import SpriteKit
import GameplayKit

final class Aim: SKSpriteNode {
    
    static func populate() -> Aim {
        let aim = Aim(imageNamed: "aim")
        aim.size = CGSize(width: 64, height: 64)
        aim.position = randomPoint()
        aim.name = "aimNode"
        return aim
    }
    
    fileprivate static func randomPoint() -> CGPoint {
        let screen = UIScreen.main.bounds
        let distributionY = GKRandomDistribution(lowestValue: 32,
                                                 highestValue: Int(screen.size.height - 128))
        let distributionX = GKRandomDistribution(lowestValue: 32,
                                                 highestValue: Int(screen.size.width - 32))
        let y = CGFloat(distributionY.nextInt())
        let x = CGFloat(distributionX.nextInt())
        return CGPoint(x: x, y: y)
    }
}
