//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by ulyana on 28.01.25.
//

import Foundation

final class ImagesListService {
    
    // MARK: - Singleton
    
    static let shared = ImagesListService()
    private init() {}
    
    // MARK: - Constants
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let networkClient = NetworkClient()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let dateFormatter: ISO8601DateFormatter = {
          let formatter = ISO8601DateFormatter()
          return formatter
      }()
    
    // MARK: - Private Properties
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    // MARK: - Public Methods
    
    func cleanImagesList() {
        photos.removeAll()
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else {
            print("[ImagesListService]:[fetchPhotosNextPage]")
            return
        }
        task?.cancel()
        
        let nextPage = (lastLoadedPage ?? 0) + 1
            
        guard let request = makeImageListRequest(nextPage: nextPage) else {
            print("[ImagesListService]:[fetchPhotosNextPage]: invalidRequest")
            return
        }
            
        let task = networkClient.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photoResult):
                for result in photoResult {
                    let photo = Photo (
                        id: result.id,
                        size: CGSize(width: result.width, height: result.height),
                        createdAt: {
                            if let dateString = result.createdAt {
                                return self?.dateFormatter.date(from: dateString)
                            } else {
                                return nil
                            }
                        }(),
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.full,
                        isLiked: result.likedByUser)
                    self?.photos.append(photo)
                }
                
                NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                self?.lastLoadedPage = nextPage
            case .failure(let error):
                print("[ImagesListService]:[fetchPhotosNextPage]:network or request error: \(error.localizedDescription)")
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let request = makeChangeLikeRequest(photoId: photoId,  isLike: isLike) else {
            print("[ImagesListService]:[changeLike]: invalidRequest")
            return
        }
        
        let task = networkClient.objectTask(for: request) { [weak self] (result: Result<PhotoLikedResult, Error>) in
            switch result {
            case .success(let photoLikedResult):
                let photo = Photo(
                    id: photoLikedResult.photo.id,
                    size: CGSize(width: photoLikedResult.photo.width, height: photoLikedResult.photo.height),
                    createdAt: {
                        if let dateString = photoLikedResult.photo.createdAt {
                            return self?.dateFormatter.date(from: dateString)
                        }
                        return nil
                    }(),
                    welcomeDescription: photoLikedResult.photo.description,
                    thumbImageURL: photoLikedResult.photo.urls.thumb,
                    largeImageURL: photoLikedResult.photo.urls.full,
                    isLiked: photoLikedResult.photo.likedByUser)
                    
                guard let index = self?.photos.firstIndex(where: {$0.id == photoId}) else { return }
                self?.photos[index].isLiked = photo.isLiked
            
                completion(.success(true))
            case .failure(let error):
                print("[ImagesListService]:[changeLike]:network or request error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
        
    // MARK: - Private Methods
    
    private func makeImageListRequest(nextPage: Int) -> URLRequest? {
        guard let url = URL(string: ImagesListConstants.unSplashImagesListURLString + "?page=\(nextPage)"),
              let token = oAuth2TokenStorage.token
        else {
            assertionFailure("[ImagesListService: makeImageListRequest]: Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        lastLoadedPage = nextPage
        return request
    }
    
    private func makeChangeLikeRequest(photoId: String,  isLike: Bool) -> URLRequest? {
        guard let url = URL(string: ImagesListConstants.unSplashImagesListURLString + "/\(photoId)/like"),
              let token = oAuth2TokenStorage.token
        else {
            assertionFailure("[ImagesListService: makeChangeLikeRequest]: Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
