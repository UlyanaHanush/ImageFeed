//
//  Photo.swift
//  ImageFeed
//
//  Created by ulyana on 28.01.25.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    init(photoResult: PhotoResult) {
          id = photoResult.id
          size = CGSize(width: photoResult.width, height: photoResult.height)
          createdAt = ISO8601DateFormatter().date(from: photoResult.createdAt)
          welcomeDescription = photoResult.description
          thumbImageURL = photoResult.urls.thumb
          largeImageURL = photoResult.urls.full
          isLiked = photoResult.likedByUser
    }
}
