//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by ulyana on 4.01.25.
//

import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
