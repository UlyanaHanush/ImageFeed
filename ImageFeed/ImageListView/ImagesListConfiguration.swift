//
//  ImagesListConfiguration.swift
//  ImageFeed
//
//  Created by ulyana on 18.02.25.
//

import Foundation

enum ImagesListConstants {
    static let unSplashImagesListURLString = "https://api.unsplash.com/photos"
}

struct ImagesListConfiguration {

    let imagesListURLString: String
    
    init(imagesListURLString: String) {
        self.imagesListURLString = imagesListURLString
    }
    
    static var standard: ImagesListConfiguration {
        return ImagesListConfiguration(imagesListURLString: ImagesListConstants.unSplashImagesListURLString)
    }
}
