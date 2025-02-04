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
    
    // MARK: - Private Properties
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    // MARK: - Public Methods
    
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
                let photo = photoResult.map { Photo(photoResult: $0) }
                self?.photos.append(contentsOf: photo)
                
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
}
