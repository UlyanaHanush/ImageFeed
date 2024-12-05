//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by ulyana on 4.12.24.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return } // 1
            imageView.image = image // 2
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
