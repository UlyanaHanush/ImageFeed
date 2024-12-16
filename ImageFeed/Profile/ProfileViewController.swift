//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by ulyana on 1.12.24.
//
import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Public Properties
    
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
        
        self.addSubviews()
        self.setupConstraints()
        
        view.backgroundColor = .ypBlack
    }
    
    // MARK: - Private Methods
    
    private func addSubviews() {
        view.addSubview(avatarImageView)
        view.addSubview(logoutButton)
        view.addSubview(nameLable)
        view.addSubview(loginNameLable)
        view.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        
        // avatarImageView Constraints
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor).isActive = true
        
        // logoutButton Constraints
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
        
        // nameLable Constraints
        nameLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLable.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
        
        // loginNameLable Constraints
        loginNameLable.leadingAnchor.constraint(equalTo: nameLable.leadingAnchor).isActive = true
        loginNameLable.topAnchor.constraint(equalTo: nameLable.bottomAnchor, constant: 8).isActive = true
        
        // descriptionLabel Constraints
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLable.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLable.bottomAnchor, constant: 8).isActive = true
    }
    
    @objc
    private func didTapButton() {}
}
