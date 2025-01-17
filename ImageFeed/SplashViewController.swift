//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by ulyana on 6.01.25.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    static let shared = SplashViewController()
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service.shared
    private var profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - UIViewController(*)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
        } else {
            // Show Auth Screen
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    
    /// Переход на флоу галереи
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        // Создаём экземпляр корневого контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

// MARK: - Segue

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            
            // Доберёмся до первого контроллера в навигации. Мы помним, что в программировании отсчёт начинается с 0?
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            }
            // Установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true)
        guard let token = OAuth2TokenStorage().token else { return }
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] (result: Result<Profile, Error>) in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                print("Profile was not found:\(error)")
                break
            }
        }
    }
}
