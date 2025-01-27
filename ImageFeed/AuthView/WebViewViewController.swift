//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by ulyana on 19.12.24.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    // получил код
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    // пользователь нажал кнопку назад и отменил авторизацию
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private lazy var webView: WKWebView = {
        let preferences = WKPreferences()
                
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
                
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
                
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true

        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var progressView = UIProgressView()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        
        let imageButton = UIImage(named: "nav_back_button")
        button.setImage(imageButton , for: .normal)
        
        button.addTarget(nil, action: #selector(didTapBackButton(_:)), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - UIViewController(*)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        
        webView.navigationDelegate = self
        loadAuthView()
        
        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: [], changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            self.updateProgress()
        })
    }
    
    // MARK: - IBAction
    
    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: super.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: super.view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: super.view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.widthAnchor.constraint(equalToConstant: 64)
        ])
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubviews() {
        
        progressView.tintColor = .ypBlack
        
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(backButton)
        view.backgroundColor = .white

        setupConstraints()
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        // fabs формула сравнения двух дробных чисел (Double, Float, CGFloat, TimeInterval)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    /// формирует URL в соответствии с документацией UnSplash и направляет пользователя на страницу авторизации
    private func loadAuthView() {
        // инициализация структуры URLComponents с указанием адреса запроса
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
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    ///  Запрашивает у делегата разрешение на навигационные действия на основе информации
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            // сообщаем AuthViewController что код авторизации получен
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
            // Пверяет, есть ли в URLComponents компоненты запроса
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
