//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by ulyana on 4.01.25.
//

import UIKit

final class OAuth2TokenStorage {
    private let tokenKey = "Bearer Token"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
