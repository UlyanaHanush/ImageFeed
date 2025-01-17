//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by ulyana on 17.01.25.
//

import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let small: String
}

enum ProfileImageConstants {
    static let unsplashProfileImageURLString = "https://api.unsplash.com//users/"
}

final class ProfileImageService {
    
    // MARK: - Singleton
    
    static let shared = ProfileImageService()
    private init() {}
    
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
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastUserName = username
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(ProfileServiceError.invalidURL))
            return
        }
        
        let task = networkClient.data(for: request) { [weak self] (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                    let profileImageURL = userResult.profileImage.small
                    
                    self?.avatarURL = profileImageURL
                    completion(.success(profileImageURL))
                } catch {
                    print("Ошибка декодирования ответа: \(error)")
                    completion(.failure(ProfileServiceError.decodingError))
                }
            case .failure(let error):
                print("Ошибка сети или запроса: \(error)")
                completion(.failure(ProfileServiceError.decodingError))
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
