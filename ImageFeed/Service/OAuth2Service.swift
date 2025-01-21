//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by ulyana on 30.12.24.
//

import UIKit

final class OAuth2Service {
    
    // MARK: - Constants
    
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Private Properties
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private var networkClient = NetworkClient()

    // MARK: - Public Methods
    
    /// десериализация данных и обработка ошибок
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания запроса"])))
            return
        }
        
        networkClient.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    // сохраняем токен
                    self.oauth2TokenStorage.token = tokenResponse.accessToken
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    print("Ошибка декодирования ответа: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Ошибка сети или запроса: \(error)")
                completion(.failure(error))
            }
        }.resume()
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
            assertionFailure("Не удалось создать URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
