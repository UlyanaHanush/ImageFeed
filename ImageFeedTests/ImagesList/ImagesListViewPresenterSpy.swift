//
//  ImagesListViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by ulyana on 17.02.25.
//

import Foundation
import ImageFeed

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    
    var imagesListService: ImagesListServiceProtocol?
    
    var view: ImagesListViewControllerProtocol?
    
    var photos: [ImageFeed.Photo] = []
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateTableViewAnimated() {
    }
    
    func loadImages() {
    }
    
    func didChangeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, any Error>) -> Void) {
    }
}
