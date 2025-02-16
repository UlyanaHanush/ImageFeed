//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by ulyana on 16.02.25.
//

import Foundation

enum Constants {
    // значение client_id — код доступа приложения
    static let accessKey = "_b2C1-RnRhbO9IiFCKiYubFemfG7B7HR3g5akaaOF6o"
    static let secretKey = "h5pJZWlIvtVyXNhavixtMUEmSKCzX4vU4jYTP5S6vH0"
    // URI, который обрабатывает успешную авторизацию пользователя
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    // значение scope — списка доступов, разделённых плюсом
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unSplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey, secretKey: Constants.secretKey, redirectURI: Constants.redirectURI, accessScope: Constants.accessScope, defaultBaseURL: Constants.defaultBaseURL, authURLString: Constants.unSplashAuthorizeURLString)
    }
}
