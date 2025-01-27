//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by ulyana on 30.12.24.
//

import UIKit

final class OAuth2Service {
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Private Properties
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private var networkClient = NetworkClient()
    
    private let urlSession = URLSession.shared
    // последняя созданная задача
    private var task: URLSessionTask?
    // Переменная для хранения значения code, которое было передано в последнем созданном запросе.
    private var lastCode: String?

    // MARK: - Public Methods
    
    /// десериализация данных и обработка ошибок
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(Auth2ServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(Auth2ServiceError.invalidRequest))
            return
        }
        
        let task = networkClient.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenResponse):
                // сохраняем токен
                self?.oAuth2TokenStorage.token = tokenResponse.accessToken
                completion(.success(tokenResponse.accessToken))
            case .failure(let error):
                print("[OAuth2Service]: [fetchOAuthToken]: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    /// URLRequest из составных компонентов
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = URL(string: "https://unsplash.com")
        
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
