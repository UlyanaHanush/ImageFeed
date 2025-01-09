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
}
