//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by ulyana on 1.12.24.
//
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let profileService = ProfileService.shared
    private let splashViewController = SplashViewController.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Photo"))
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapButton))
        button.tintColor = .ipadAndArrowForward
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = .ypWhite
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .loginNameLabel
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .ypWhite
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - UIViewController(*)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creatingView()
        profileImageServiceObserver()
        imageListServiceObserver()
        updateAvatar()
    }
    
    // MARK: - Public Methods
    
    private func switchToSplashViewController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
    private func imageListServiceObserver() {
        NotificationCenter.default.addObserver(
            forName: ProfileLogoutService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            switchToSplashViewController()
        }
    }
    
    // MARK: - Private Methods
    
    private func creatingView() {
        addSubviews()
        setupConstraints()
        
        updateProfileDetails()
        view.backgroundColor = .ypBlack
    }
    
    private func addSubviews() {
        view.addSubview(avatarImageView)
        view.addSubview(logoutButton)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
        // avatarImageView Constraints
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        avatarImageView.widthAnchor.constraint(equalToConstant: 70),
        avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
        
        // logoutButton Constraints
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
        
        // nameLabel Constraints
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
        
        // loginNameLabel Constraints
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        
        // descriptionLabel Constraints
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            print("[ProfileViewController]: Profile was not found")
            return
        }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "Photo"), options: [.processor(processor)])
    }
    
    private func profileImageServiceObserver() {
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
    }
        
    @objc
    private func didTapButton() {
        let alert = UIAlertController(
            title: "Пока пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert)
        
        let actionYes = UIAlertAction(title: "Да", style: .default) { _ in
            self.profileLogoutService.logout()
        }
        let actionNo = UIAlertAction(title: "Нет", style: .default) { _ in }
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        
        self.present(alert, animated: true, completion: nil)
    }
}
