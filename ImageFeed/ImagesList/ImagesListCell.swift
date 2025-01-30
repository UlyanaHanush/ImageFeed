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
    
    ///  идентификатор ячейки
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
}
