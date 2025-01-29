//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by ulyana on 28.01.25.
//

//import Foundation
//
//final class ImagesListService {
//    
//    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
//    
//    private (set) var photos: [Photo] = []
//    private(set) var photo: Photo?
//    private var lastLoadedPage: Int?
//    
//    private let networkClient = NetworkClient()
//    private let oAuth2TokenStorage = OAuth2TokenStorage()
//    
//    private let urlSession = URLSession.shared
//    // это указателя на последнюю созданную задачу
//    private var task: URLSessionTask?
//    // Переменная для хранения значения code, которое было передано в последнем созданном запросе.
//    private var lastToken: String?
//    
//    func fetchPhotosNextPage(token: String ,completion: @escaping (Result<Photo, Error>) -> Void) {
//
//        // let nextPage = (lastLoadedPage?.number ?? 0) + 1
//        let nextPage = (lastLoadedPage ?? 0) + 1
//        
//        assert(Thread.isMainThread)
//        guard lastToken != token else {
//            completion(.failure(ImagesListServiceError.invalidRequest))
//            return
//        }
//        task?.cancel()
//        lastToken = token
//            
//        guard let request = makeImageListRequest(nextPage: nextPage, token: token) else {
//            completion(.failure(ImagesListServiceError.invalidURL))
//            return
//        }
//            
//        let task = networkClient.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
//            switch result {
//            case .success(let photoResult):
//                let photo = Photo(
//                    id: photoResult.id,
//                    size: CGSize(width: photoResult.width, height: photoResult.height),
//                    createdAt: photoResult.createdAt,
//                    welcomeDescription: photoResult.description,
//                    thumbImageURL: photoResult.urlsResult.thumb,
//                    largeImageURL: photoResult.urlsResult.full,
//                    isLiked: photoResult.likedByUser)
//                
//                self?.photos.append(photo)
//                self?.photo = photo
//                completion(.success(photo))
//
//            case .failure(let error):
//                print("Network or request error: \(error.localizedDescription)")
//                completion(.failure(ImagesListServiceError.decodingError))
//            }
//            self?.task = nil
//            self?.lastToken = nil
//        }
//        self.task = task
//        task.resume()
//    }
//        
//    // MARK: - Private Methods
//    
//    private func makeImageListRequest(nextPage: Int, token: String) -> URLRequest? {
//        guard let url = URL(string: ImagesListConstants.unSplashImagesListURLString + "?page=\(nextPage)"),
//              let token = oAuth2TokenStorage.token
//        else {
//            assertionFailure("[ImagesListService: makeImageListRequest]: Failed to create URL")
//            return nil
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        lastLoadedPage = nextPage
//        return request
//    }
//}
//
//
