//
//  GameScene.swift
//  AimTrainer
//
//  Created by Myhovych on 04.11.2021.
//

import SpriteKit

class GameScene: SKScene {
    
    private let scoreLabel = SKLabelNode()
    private let highscoreLabel = SKLabelNode()
    private let timeLabel = SKLabelNode()
    private var touchNode : SKShapeNode?
    
    private var time: TimeInterval = 8.0
    private var currentElapsedTime: TimeInterval = 0.0
    private var updateTime: TimeInterval = 0.0
    private var score: Int = 0
    private var isGameOver: Bool = false
    private let fontSize: CGFloat = 20.0
    
    private var networkManager = NetworkManager()
    
    override func didMove(to view: SKView) {
        configureStartScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - updateTime
        currentElapsedTime += delta
        if currentElapsedTime > 1 {
            time -= 1
            if time >= 0 {
                updateTimeLabel()
            }
            currentElapsedTime = 0.0
        }
        updateTime = currentTime
        if time == 0, !isGameOver {
            gameOver()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchPosition = touch.location(in: self)
        let node = self.atPoint(touchPosition)
        if node.name == "aimNode" {
            removeAim()
            spawnAim()
            score += 1
            updateScoreLabel()
        }
        touchDown(atPoint: touch.location(in: self), isHit: node.name == "aimNode")
    }
    
    fileprivate func configureStartScene() {
        backgroundColor = .white
        
        configureLabels()
        configureBar()
        configureTouchNode()
        spawnAim()
    }
    
    fileprivate func configureLabels() {
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = .black
        scoreLabel.verticalAlignmentMode = .center
        
        highscoreLabel.fontSize = fontSize
        highscoreLabel.fontColor = .black
        highscoreLabel.verticalAlignmentMode = .center
        highscoreLabel.text = "Highscore: \(GameManager.highscore())"
        
        timeLabel.fontSize = fontSize
        timeLabel.fontColor = .black
        timeLabel.verticalAlignmentMode = .center
        timeLabel.text = "Time: \(time)"
    }
    
    fileprivate func configureBar() {
        let bar = SKSpriteNode(color: .clear, size: CGSize(width: frame.size.width, height: frame.size.height / 12))
        bar.zPosition = 0
        bar.position = CGPoint(x: 0, y: frame.size.height - (2 * bar.size.height))
        bar.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(bar)
        
        scoreLabel.position = CGPoint(x: 64, y: bar.size.height / 2)
        bar.addChild(scoreLabel)
        
        highscoreLabel.position = CGPoint(x: bar.frame.midX, y: bar.size.height / 2)
        bar.addChild(highscoreLabel)
        
        timeLabel.position = CGPoint(x: bar.frame.maxX - 64, y: bar.size.height / 2)
        bar.addChild(timeLabel)
    }
    
    fileprivate func configureTouchNode() {
        self.touchNode = SKShapeNode(circleOfRadius: 16)
        if let spinnyNode = self.touchNode {
            spinnyNode.lineWidth = 2.5
            spinnyNode.strokeColor = .red
            spinnyNode.run(SKAction.scale(to: 2, duration: 0.5))
            spinnyNode.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()]))
        }
    }
    
    fileprivate func spawnAim() {
        let spawnAimWait = SKAction.wait(forDuration: 0.1)
        let spawnAimAction = SKAction.run {
            let aim = Aim.populate()
            self.addChild(aim)
        }
        let spawnAimSequence = SKAction.sequence([spawnAimWait, spawnAimAction])
        run(spawnAimSequence)
    }
    
    fileprivate func removeAim() {
        let removeAimAction = SKAction.run {
            self.enumerateChildNodes(withName: "aimNode") { node, stop in
                node.removeFromParent()
            }
        }
        let removeAimSequence = SKAction.sequence([removeAimAction])
        run(removeAimSequence)
    }
    
    fileprivate func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    fileprivate func updateTimeLabel() {
        timeLabel.text = "Time: \(time)"
    }
    
    fileprivate func touchDown(atPoint pos : CGPoint, isHit: Bool) {
        if let n = self.touchNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = isHit ? SKColor.green : SKColor.red
            self.addChild(n)
        }
    }
    
    fileprivate func gameOver() {
        print("Game Over 👾")
        isGameOver = true
        if score > GameManager.highscore() {
            GameManager.setHighscore(score)
        }
        networkManager.fetchGameOverLinks()
        networkManager.completion = { [weak self] gameOverLinks in
            guard let self = self else { return }
            let gameOverLink = self.score < 10 ? gameOverLinks.loser : gameOverLinks.winner
            DispatchQueue.main.async {
                self.postGameOverNotificaiton(with: gameOverLink)
                self.showMenuScene()
            }
        }
    }
    
    fileprivate func postGameOverNotificaiton(with url: String) {
        NotificationCenter.default.post(name: NSNotification.Name("GameOver"), object: nil, userInfo: ["url" : url])
    }
    
    fileprivate func showMenuScene() {
        let scene = MenuScene(size: UIScreen.main.bounds.size)
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }
}
