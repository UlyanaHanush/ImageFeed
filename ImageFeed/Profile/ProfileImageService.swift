//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by ulyana on 17.01.25.
//

import Foundation

final class ProfileImageService {
    
    // MARK: - Singleton
    
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: - Public Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private var networkClient = NetworkClient()
    private (set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    // указателя на последнюю созданную задачу
    private var task: URLSessionTask?
    // Переменная для хранения значения code, которое было передано в последнем созданном запросе.
    private var lastUserName: String?

    // MARK: - Public Methods
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastUserName != username else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastUserName = username
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(ProfileImageServiceError.invalidURL))
            return
        }
        
        let task = networkClient.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small
                self?.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                    
                NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])

            case .failure(let error):
                print("Network or request error: \(error)")
                completion(.failure(ProfileImageServiceError.decodingError))
            }
            self?.task = nil
            self?.lastUserName = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    /// URLRequest из составных компоненто
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            assertionFailure("[ProfileImageService: makeProfileImageRequest]: Failed to create URL")
            return nil
        }
        
        guard let url = URL(string: "/users/\(username)", relativeTo: baseURL) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = oauth2TokenStorage.token else {
            assertionFailure("[ProfileImageService: makeProfileImageRequest]: Failed token")
            return nil
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
