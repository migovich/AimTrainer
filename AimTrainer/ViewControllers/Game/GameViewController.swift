//
//  GameViewController.swift
//  AimTrainer
//
//  Created by Myhovych on 04.11.2021.
//

import SpriteKit

class GameViewController: UIViewController {
    var scene: MenuScene?

    override func loadView() {
        super.loadView()
        self.view = SKView()
        self.view.bounds = UIScreen.main.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScene()
    }

    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showGameOverScreen(_:)), name: NSNotification.Name("GameOver"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTutorialPopup), name: NSNotification.Name("ShowTutorial"), object: nil)
    }
    
    fileprivate func setupScene() {
        if let view = self.view as? SKView, scene == nil {
            let scene = MenuScene(size: view.bounds.size)
            view.presentScene(scene)
            self.scene = scene
        }
    }
    
    @objc fileprivate func showGameOverScreen(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let url = userInfo["url"] as? String else {
            return
        }
        let vc = UIStoryboard(name: GameOverViewController.className, bundle: nil).instantiateViewController(withIdentifier: GameOverViewController.className) as! GameOverViewController
        vc.configure(url: url)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func showTutorialPopup() {
        let vc = UIStoryboard(name: TutorialViewController.className, bundle: nil).instantiateViewController(withIdentifier: TutorialViewController.className)
        present(vc, animated: true, completion: nil)
    }
}
