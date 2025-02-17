//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by ulyana on 17.02.25.
//

import Foundation

protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func didUpdateTableViewAnimated()
    func loadImages()
    func didChangeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void)
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    // MARK: - Public Properties
    
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    // MARK: - Private Properties
    
    let imagesListService = ImagesListService.shared
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        imageListServiceObserver()
        imagesListService.fetchPhotosNextPage()
    }
    
    func didUpdateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if newCount != oldCount {
            view?.oldCount = oldCount
            view?.newCount = newCount
            view?.updateTableViewAnimated()
        }
    }
    
    func loadImages() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func didChangeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let isLiked):
                guard let index = photos.firstIndex(where: {$0.id == photoId}) else { return }
                photos[index].isLiked = isLiked
                completion(.success(isLiked))
                
            case .failure(let error):
                completion(.failure(error))
                print("[ImagesListViewController]:[imageListCellDidTapLike] \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func imageListServiceObserver() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            didUpdateTableViewAnimated()
        }
    }
}
