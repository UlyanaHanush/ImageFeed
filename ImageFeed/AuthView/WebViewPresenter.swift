//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by ulyana on 16.02.25.
//

import Foundation
import WebKit

public protocol WebViewPresenterProtocol {
    var view: WebViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: WebViewControllerProtocol?
    
    // MARK: - Public Methods
    
    /// направляет пользователя на страницу авторизации
    func viewDidLoad() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unSplashAuthorizeURLString) else {
            print("Error: init URLComponents")
            return
        }
        
        urlComponents.queryItems = [
            // значение client_id — код доступа к приложению
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            // URI, который обрабатывает успешную авторизацию пользователя
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            // тип ответа, который мы ожидаем. Unsplash ожидает значения code
            URLQueryItem(name: "response_type", value: "code"),
            // значение scope — списка доступов, разделённых плюсом
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Error: creating url")
            return
        }
        
        let request = URLRequest(url: url)
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    /// функция code(from:) возвращает код авторизации, если он получен
    func code(from url: URL) -> String? {
        if
            // Получаем значения компонентов из URL
            let urlComponents = URLComponents(string: url.absoluteString),
            // Проверяем, совпадает ли адрес запроса с адресом получения кода
            urlComponents.path == "/oauth/authorize/native",
            // Проверяет, есть ли в URLComponents компоненты запроса
            let items = urlComponents.queryItems,
            // Ищем в массиве компонентов такой компонент, у которого значение name == code.
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
