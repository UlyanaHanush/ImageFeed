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
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service.shared
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
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
        } else {
            print("[SplashViewController: viewDidAppear]: token was not found")
        }
        
        creatingView()
        showAuthViewController()
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
        _ = UIStoryboard(name: "Main", bundle: .main)
        
        let tabBarController = TabBarController()
        
//        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
//            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashScreenLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ,
            splashScreenLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func creatingView() {
        view.addSubview(splashScreenLogoImageView)
        setupConstraints()
        view.backgroundColor = .ypBlack
    }
    
    private func showAuthViewController() {
        _ = UIStoryboard(name: "Main", bundle: nil)
        
        let authViewController = AuthViewController()
        
        authViewController.delegate = self
           
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
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
