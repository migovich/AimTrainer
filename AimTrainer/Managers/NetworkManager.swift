//
//  NetworkManager.swift
//  AimTrainer
//
//  Created by Myhovych on 04.11.2021.
//

import Foundation

class NetworkManager {
    
    var completion: ((GameOverLinks) -> ())?
    
    func fetchGameOverLinks() {
        guard let url = URL(string: "https://2llctw8ia5.execute-api.us-west-1.amazonaws.com/prod") else {
            return
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                if let gameOverLinks = self.parseJSON(withData: data) {
                    self.completion?(gameOverLinks)
                }
            }
        }
        task.resume()
    }
    
    func parseJSON(withData data: Data) -> GameOverLinks? {
        let decoder = JSONDecoder()
        do {
            let gameOverLinks = try decoder.decode(GameOverLinks.self, from: data)
            return gameOverLinks
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
