//
//  Constants.swift
//  ImageFeed
//
//  Created by ulyana on 17.12.24.
//

import Foundation

// MARK: - ProfileView

enum ProfileViewConstants {
    static let unSplashProfileURLString = "https://api.unsplash.com/me"
}

// MARK: - ProfileImage

enum ProfileImageConstants {
    static let unSplashProfileImageURLString = "https://api.unsplash.com//users/"
}

// MARK: - Auth2ServiceError

enum Auth2ServiceError: Error {
    case invalidRequest
}

// MARK: - ProfileView

enum ImagesListConstants {
    static let unSplashImagesListURLString = "https://api.unsplash.com/photos"
}
