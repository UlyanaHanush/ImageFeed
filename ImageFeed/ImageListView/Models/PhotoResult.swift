//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by ulyana on 28.01.25.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case width
        case height
        case description
        case likedByUser
        case urls
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

struct PhotoLikedResult: Decodable {
    let photo: PhotoResult
}
