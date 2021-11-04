//
//  GameOverViewController.swift
//  AimTrainer
//
//  Created by Myhovych on 04.11.2021.
//

import UIKit
import WebKit

class GameOverViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private weak var webView: WKWebView!
    
    // MARK: Properties
    private var url: String = ""
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sendRequest(urlString: url)
    }
    
    // MARK: Functions
    func configure(url: String) {
        self.url = url
    }
    
    fileprivate func sendRequest(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
}
