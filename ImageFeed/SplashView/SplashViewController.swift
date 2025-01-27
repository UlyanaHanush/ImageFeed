//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by ulyana on 6.01.25.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Singleton
    
    static let shared = SplashViewController()
    
    // MARK: - Private Properties
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private var profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private lazy var splashScreenLogoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Vector"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - UIViewController(*)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oAuth2TokenStorage.token {
            fetchProfile(token)
        } else {
            showAuthViewController()
            print("[SplashViewController: viewDidAppear]: token was not found")
        }
        creatingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    
    /// Переход на галерею фотографий
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashScreenLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashScreenLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func creatingView() {
        view.addSubview(splashScreenLogoImageView)
        setupConstraints()
        view.backgroundColor = .ypBlack
    }
    
    private func showAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
           
        present(authViewController, animated: true, completion: nil)
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true)
        
        guard let token = oAuth2TokenStorage.token else { return }
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
