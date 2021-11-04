//
//  UserDefaults+Extension.swift
//  AimTrainer
//
//  Created by Myhovych on 04.11.2021.
//

import Foundation

extension UserDefaults {
    func isFirstLaunch() -> Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: #function)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: #function)
        }
        return isFirstLaunch
    }
}
