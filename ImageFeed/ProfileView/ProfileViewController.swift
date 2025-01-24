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
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Photo"))
        
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
    
    private lazy var nameLable: UILabel = {
        let lable = UILabel()
        lable.text = "Екатерина Новикова"
        lable.font = .boldSystemFont(ofSize: 23)
        lable.textColor = .ypWhite
        
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
    
    private lazy var loginNameLable: UILabel = {
        let lable = UILabel()
        lable.text = "@ekaterina_nov"
        lable.font = .systemFont(ofSize: 13)
        lable.textColor = .loginNameLable
        
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let lable = UILabel()
        lable.text = "Hello, World!"
        lable.font = .systemFont(ofSize: 13)
        lable.textColor = .ypWhite
        
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
    
    // MARK: - UIViewController(*)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creatingView()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
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
        view.addSubview(nameLable)
        view.addSubview(loginNameLable)
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
        
        // nameLable Constraints
        nameLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        nameLable.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
        
        // loginNameLable Constraints
        loginNameLable.leadingAnchor.constraint(equalTo: nameLable.leadingAnchor),
        loginNameLable.topAnchor.constraint(equalTo: nameLable.bottomAnchor, constant: 8),
        
        // descriptionLabel Constraints
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLable.leadingAnchor),
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLable.bottomAnchor, constant: 8)
        ])
    }
    
    private func updateProfileDetails() {
        if let profile = profileService.profile {
            nameLable.text = profile.name
            loginNameLable.text = profile.loginName
            descriptionLabel.text = profile.bio
        } else {
            print("profile was not found")
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "Photo"), options: [.processor(processor)])
    }
        
    @objc
    private func didTapButton() {}
}
