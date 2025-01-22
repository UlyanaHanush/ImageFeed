//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by ulyana on 18.01.25.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}
