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
}
