//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by ulyana on 3.01.25.
//

import UIKit

struct NetworkClient {
    
    // MARK: - Error
    
    private enum NetworkError: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    // MARK: - Public Methods
    
    /// отправка запроса и разбор ответа от сервера
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        
        // замыкание fulfillCompletionOnTheMainThread будет выполнять любой код на главном потоке.
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    // Возвращаем полученное тело ответа как успешный результат работы запроса
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    // Возвращаем ошибку, связанную с неблагоприятным диапазоном статуса кода ответа
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                // Возвращаем ошибку, которую получили в результате работы URLSession.dataTask — сетевую ошибку
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                // Возвращаем ошибку, связанную с остальными случаями
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Ошибка декодирования ответа: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Ошибка сети или запроса: \(error)")
                completion(.failure(error))
            }
        }
        return task
    }
}
