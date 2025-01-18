//
//  UserResult.swift
//  ImageFeed
//
//  Created by ulyana on 18.01.25.
//

import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
