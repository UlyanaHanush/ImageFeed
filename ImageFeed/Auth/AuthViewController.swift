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
                fatalError("Failed to prepare for \(showWebViewSegueIdentifier)")
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    
    /// сообщает SplashViewController что получен токен
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        // // блокирует пользовательское взаимодействие и включает анимацию
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(with: code) { [weak self] (result: Result<String, Error>) in
            guard let self = self else { return }
            
            // разблокирует пользовательского взаимодействия и выключит анимацию
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let token):
                delegate?.didAuthenticate(self, didAuthenticateWithCode: code)
                oauth2TokenStorage.token = token
                print("Успешно получен токен: \(token)")
            case .failure(let error):
                print("Ошибка авторизации: \(error.localizedDescription)")
            }
        }
    }
           
    ///  возвращает на AuthViewController, отменяя показ WebView
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
