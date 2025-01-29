//
//  Errors.swift
//  ImageFeed
//
//  Created by ulyana on 18.01.25.
//

import Foundation

// MARK: - ProfileService

enum ProfileServiceError: Error {
    case invalidRequest
    case invalidURL
    case decodingError
}

// MARK: - ProfileImageService

enum ProfileImageServiceError: Error {
    case invalidRequest
    case invalidURL
    case decodingError
}

// MARK: - ImagesListService

enum ImagesListServiceError: Error {
    case invalidRequest
    case invalidURL
    case decodingError
}
