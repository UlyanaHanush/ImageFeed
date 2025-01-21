//
//  Constants.swift
//  ImageFeed
//
//  Created by ulyana on 17.12.24.
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
}
