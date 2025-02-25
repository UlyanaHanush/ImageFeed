//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by ulyana on 17.02.25.
//

import Foundation

public protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var imagesListService: ImagesListServiceProtocol? { get }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func didUpdateTableViewAnimated()
    func loadImages()
    func didChangeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void)
    
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var imagesListService: ImagesListServiceProtocol?
    
    // MARK: - Init
    
    init(imagesListService: ImagesListServiceProtocol? = ImagesListService.shared) {
            self.imagesListService = imagesListService
        }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        imageListServiceObserver()
        imagesListService?.fetchPhotosNextPage()
    }
    
    func didUpdateTableViewAnimated() {
        let oldCount = photos.count
        guard let newCount = imagesListService?.photos.count else { return }
        guard let photos = imagesListService?.photos else { return }
        self.photos = photos
        if newCount != oldCount {
            view?.oldCount = oldCount
            view?.newCount = newCount
            view?.updateTableViewAnimated()
        }
    }
    
    func loadImages() {
        imagesListService?.fetchPhotosNextPage()
    }
    
    func didChangeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        imagesListService?.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
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
