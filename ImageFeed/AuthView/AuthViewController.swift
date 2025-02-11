//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by ulyana on 18.12.24.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    // MARK: - Singleton
    
    static let shared = AuthViewController()
    
    // MARK: - Public Properties
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service.shared
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.backgroundColor = .white
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        button.addTarget(nil, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var authScreenLogoImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "auth_screen_logo"))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - UIViewController(*)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
    }
    
    // MARK: - IBAction
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        
        webViewViewController.modalPresentationStyle = .fullScreen
        present(webViewViewController, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func addSubviews() {
        view.addSubview(enterButton)
        view.addSubview(authScreenLogoImage)
        view.backgroundColor = .ypBlack
        
        configureBackButton()
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            enterButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            enterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            enterButton.centerXAnchor.constraint(equalTo: super.view.centerXAnchor),
            enterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            enterButton.heightAnchor.constraint(equalToConstant: 48),
            
            authScreenLogoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authScreenLogoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }

    private func showNetworkError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet
        
        // в замыкании пишем, что должно происходить при нажатии на кнопку
        let action = UIAlertAction(title: "Ок", style: .default) { _ in }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    /// сообщает SplashViewController что получен токен
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        // // блокирует взаимодействие пользователя и включает анимацию
        UIBlockingProgressHUD.show()
        
        oAuth2Service.fetchOAuthToken(with: code) { [weak self] result in
            guard let self = self else { return }
            
            // разблокирует взаимодействия пользователя и выключит анимацию
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let token):
                delegate?.didAuthenticate(self, didAuthenticateWithCode: code)
                oAuth2TokenStorage.token = token
                
                print("Токе успешно получен: \(token)")
            case .failure(let error):
                print("[AuthViewController: webViewViewController]: \(error.localizedDescription)")
                showNetworkError()
            }
        }
    }
           
    ///  возвращает на AuthViewController, отменяя показ WebView
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
