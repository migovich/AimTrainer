//
//  GameScene.swift
//  AimTrainer
//
//  Created by Myhovych on 04.11.2021.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: Node properties
    private let scoreLabel = SKLabelNode()
    private let highscoreLabel = SKLabelNode()
    private let timeLabel = SKLabelNode()
    private var touchNode : SKShapeNode?
    
    // MARK: Stored properties
    private var gameTime: Int = 7 {
        didSet {
            timeLabel.text = "Time: \(gameTime)"
        }
    }
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var isGameStarted: Bool = false

    // MARK: Dependency properties
    private var networkManager = NetworkManager()
    
    // MARK: Life Cycle
    override func didMove(to view: SKView) {
        configureStartScene()
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameStarted { return }
        guard let touch = touches.first else { return }
        let touchPosition = touch.location(in: self)
        let node = self.atPoint(touchPosition)
        if node.name == "aimNode" {
            removeAim()
            spawnAim()
            score += 1
        }
        touchDown(atPoint: touch.location(in: self), isHit: node.name == "aimNode")
    }
    
    fileprivate func configureStartScene() {
        backgroundColor = .white
        configureLabels()
        configureBar()
        configureTouchNode()
    }
    
    fileprivate func startGame() {
        print("Game Started 🎯")
        self.isGameStarted = true
        self.gameTime = 7
        self.score = 0
        spawnAim()
        configureTimer()
    }
    
    fileprivate func endGame() {
        print("Game Over 👾")
        self.isGameStarted = false
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
    
    fileprivate func configureTimer() {
        let wait = SKAction.wait(forDuration: 1)
        let block = SKAction.run { [unowned self] in
            if self.gameTime > 0 {
                self.gameTime -= 1
            } else {
                self.removeAction(forKey: "countdown")
                self.endGame()
            }
        }
        let sequence = SKAction.sequence([wait, block])
        run(SKAction.repeatForever(sequence), withKey: "countdown")
    }
    
    fileprivate func configureLabels() {
        let fontSize: CGFloat = 20.0
        let fontColor: UIColor = .black
        let alignment: SKLabelVerticalAlignmentMode = .center
        
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = fontColor
        scoreLabel.verticalAlignmentMode = alignment
        scoreLabel.text = "Score: \(score)"
        
        highscoreLabel.fontSize = fontSize
        highscoreLabel.fontColor = fontColor
        highscoreLabel.verticalAlignmentMode = alignment
        highscoreLabel.text = "Highscore: \(GameManager.highscore())"
        
        timeLabel.fontSize = fontSize
        timeLabel.fontColor = fontColor
        timeLabel.verticalAlignmentMode = alignment
        timeLabel.text = "Time: \(gameTime)"
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
    
    fileprivate func touchDown(atPoint pos : CGPoint, isHit: Bool) {
        if let n = self.touchNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = isHit ? SKColor.green : SKColor.red
            self.addChild(n)
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
