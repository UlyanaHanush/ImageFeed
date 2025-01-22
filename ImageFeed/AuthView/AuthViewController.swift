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
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - UIViewController(*)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                // segue.destination переход между контроллерами
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: -Private Methods
    
    /// приватный метод для показа алерта ошибки
    private func showNetworkError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet
        
        // в замыкании пишем, что должно происходить при нажатии на кнопку
        let action = UIAlertAction(title: "Ок", style: .default) { _ in }
        
        // добавляем в алерт кнопку
        alert.addAction(action)
        
        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    /// сообщает SplashViewController что получен токен
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        // // блокирует пользовательское взаимодействие и включает анимацию
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(with: code) { [weak self] result in
            guard let self = self else { return }
            
            // разблокирует пользовательского взаимодействия и выключит анимацию
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let token):
                delegate?.didAuthenticate(self, didAuthenticateWithCode: code)
                oauth2TokenStorage.token = token
                
                print("Успешно получен токен: \(token)")
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
