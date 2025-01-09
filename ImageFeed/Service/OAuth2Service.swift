//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by ulyana on 30.12.24.
//

import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Constants
    
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Private Properties
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private var networkClient = NetworkClient()
    
    private let urlSession = URLSession.shared
    // указателя на последнюю созданную задачу
    private var task: URLSessionTask?
    // Переменная для хранения значения code, которое было передано в последнем созданном запросе.
    private var lastCode: String?

    // MARK: - Public Methods
    
    /// десериализация данных и обработка ошибок
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = networkClient.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    // сохраняем токен
                    self?.oauth2TokenStorage.token = tokenResponse.accessToken
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    print("Ошибка декодирования ответа: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Ошибка сети или запроса: \(error)")
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    /// URLRequest из составных компоненто
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
