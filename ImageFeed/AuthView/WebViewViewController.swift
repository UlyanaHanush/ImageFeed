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

public protocol WebViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewControllerProtocol {
    
    // MARK: - Public Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
    // MARK: - Private Properties
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private lazy var webView: WKWebView = {
        let preferences = WKPreferences()
                
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
                
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
                
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.navigationDelegate = self

        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.tintColor = .ypBlack
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
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
        presenter?.viewDidLoad()
        progressObservation()
    }
    
    // MARK: - IBAction
    
    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Public Methods
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    // MARK: - Private Methods
    
    private func progressObservation() {
        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: [], changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        })
    }
    
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
    }
    
    private func addSubviews() {
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(backButton)
        view.backgroundColor = .white

        setupConstraints()
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
        // Получаем из навигационного действия navigationAction URL
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
