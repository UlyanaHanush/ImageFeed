//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by ulyana on 19.12.24.
//

import UIKit
import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerDelegate: AnyObject {
    // получил код
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    // пользователь нажал кнопку назад и отменил авторизацию
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - IBOutlet
    
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var webView: WKWebView!
    
    // MARK: - UIViewController(*)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        loadAuthView()
        updateProgress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // добавляет наблюдателя за кей-пасом
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        updateProgress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // удаляет наблюдателя за кей-пасом
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    // MARK: - Public Methods
    
    /// события об изменениях загрузки
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Private Methods
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        // fabs формула сравнения двух дробных чисел (Double, Float, CGFloat, TimeInterval)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    /// формирует URL в соответствии с документацией Unsplash
    private func loadAuthView() {
        // инициализируем структуру URLComponents с указанием адреса запроса
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Error: init URLComponents")
            return
        }
        
        urlComponents.queryItems = [
            // значение client_id — код доступа приложения
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
           webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    ///  Запрашивает у делегата разрешение на навигационные действия на основе информации
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            // отменяем навигационное действие (всё, что нужно, мы от webView уже получили)
            decisionHandler(.cancel)
        } else {
            // разрешаем навигационное действие
            decisionHandler(.allow)
        }
    }
    
    /// функция code(from:) возвращает код авторизации, если он получен
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            // Получаем из навигационного действия navigationAction URL
            let url = navigationAction.request.url,
            // Получаем значения компонентов из URL
            let urlComponents = URLComponents(string: url.absoluteString),
            // Проверяем, совпадает ли адрес запроса с адресом получения кода
            urlComponents.path == "/oauth/authorize/native",
            // Пверяем, есть ли в URLComponents компоненты запроса
            let items = urlComponents.queryItems,
            // Ищем в массиве компонентов такой компонент, у которого значение name == code.
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
