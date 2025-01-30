//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by ulyana on 28.11.24.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {

    // MARK: - Constants
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Private Properties
    
    lazy var cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 13)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var gradientImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gradientImage"))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    // MARK: - Nib
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        contentView.addSubview(cellImage)
        contentView.addSubview(likeButton)
        contentView.addSubview(gradientImage)
        contentView.addSubview(dateLabel)
        
        setupConstraints()
        contentView.backgroundColor = .ypBlack
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellImage.trailingAnchor.constraint(equalTo: super.contentView.trailingAnchor, constant: -16),
            cellImage.leadingAnchor.constraint(equalTo: super.contentView.leadingAnchor, constant: 16),
            
            cellImage.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            cellImage.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 4),
            
            likeButton.trailingAnchor.constraint(equalTo: cellImage.safeAreaLayoutGuide.trailingAnchor),
            likeButton.topAnchor.constraint(equalTo: cellImage.safeAreaLayoutGuide.topAnchor),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            
            gradientImage.trailingAnchor.constraint(equalTo: super.contentView.trailingAnchor, constant: -16),
            gradientImage.leadingAnchor.constraint(equalTo: super.contentView.leadingAnchor, constant: 16),
            gradientImage.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            gradientImage.heightAnchor.constraint(equalToConstant: 30),
            
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellImage.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
    }
}

