//
//  ProfileService.swift
//  ImageFeed
//
//  Created by ulyana on 13.01.25.
//

import Foundation

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
        
        let task = networkClient.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: profileResult.firstName + " " + (profileResult.lastName ?? ""),
                    loginName: "@" + profileResult.username,
                    bio: profileResult.bio)
                
                self?.profile = profile
                completion(.success(profile))

            case .failure(let error):
                print("Network or request error: \(error.localizedDescription)")
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
            assertionFailure("[ProfileService: makeProfileRequest]: Failed to create URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
