//
//  ProfileService.swift
//  ImageFeed
//
//  Created by ulyana on 13.01.25.
//

import Foundation

// MARK: - Struct + Enum

enum ProfileServiceError: Error {
    case invalidRequest
    case invalidURL
    case noData
    case decodingError
    case missingProfileImageURL
}

enum ProfileViewConstants {
    static let unsplashProfileURLString = "https://api.unsplash.com/me"
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username, bio
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

struct Profile {
    
    let username: String
    var name: String
    let loginName: String
    let bio: String?
}

final class ProfileService {
    
    // MARK: - Singleton
    
    static let shared = ProfileService()
    private init() {}
    
    // MARK: - Private Properties
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private var networkClient = NetworkClient()
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    // указателя на последнюю созданную задачу
    private var task: URLSessionTask?
    // Переменная для хранения значения code, которое было передано в последнем созданном запросе.
    private var lastToken: String?

    // MARK: - Public Methods
    
    /// десериализация данных и обработка ошибок
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastToken != token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidURL))
            return
        }
        
        let task = networkClient.data(for: request) { [weak self] (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    
                    let profile = Profile(
                        username: profileResult.username,
                        name: profileResult.firstName + " " + (profileResult.lastName ?? ""),
                        loginName: "@" + profileResult.username,
                        bio: profileResult.bio)
                    
                    self?.profile = profile
                    completion(.success(profile))
                } catch {
                    print("Ошибка декодирования ответа: \(error)")
                    completion(.failure(ProfileServiceError.decodingError))
                }
            case .failure(let error):
                print("Ошибка сети или запроса: \(error)")
                completion(.failure(ProfileServiceError.decodingError))
            }
            self?.task = nil
            self?.lastToken = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    /// URLRequest из составных компоненто
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: ProfileViewConstants.unsplashProfileURLString) else {
            assertionFailure("Failed to create URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
