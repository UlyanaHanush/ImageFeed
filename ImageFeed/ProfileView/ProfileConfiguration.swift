//
//  ProfileConfiguration.swift
//  ImageFeed
//
//  Created by ulyana on 18.02.25.
//

import Foundation

enum ProfileViewConstants {
    static let unSplashProfileURLString = "https://api.unsplash.com/me"
    static let unSplashProfileImageURLString = "https://api.unsplash.com//users/"
}

struct ProfileConfiguration {

    let profileURLString: String
    let profileImageURLString: String
    
    init(profileURLString: String, profileImageURLString: String) {
        self.profileURLString = profileURLString
        self.profileImageURLString = profileImageURLString
    }
    
    static var standard: ProfileConfiguration {
        return ProfileConfiguration(profileURLString: ProfileViewConstants.unSplashProfileURLString, profileImageURLString: ProfileViewConstants.unSplashProfileImageURLString)
    }
}
