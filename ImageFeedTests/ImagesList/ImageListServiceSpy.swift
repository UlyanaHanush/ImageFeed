//
//  ImageListServiceSpy.swift
//  ImageFeedTests
//
//  Created by ulyana on 18.02.25.
//

import Foundation
import ImageFeed

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var fetchPhotosNextPageCalled: Bool = false
    
    var photos: [ImageFeed.Photo] = [
        ImageFeed.Photo(
             id: "",
             size: CGSize(),
             createdAt: nil,
             welcomeDescription: nil,
             thumbImageURL: "",
             largeImageURL: "",
             isLiked: false
         ),
        ImageFeed.Photo(
             id: "",
             size: CGSize(),
             createdAt: nil,
             welcomeDescription: nil,
             thumbImageURL: "",
             largeImageURL: "",
             isLiked: false
         )]
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, any Error>) -> Void) {
    }
}
