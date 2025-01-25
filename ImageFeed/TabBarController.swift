//
//  TabBarController.swift
//  ImageFeed
//
//  Created by ulyana on 21.01.25.
//

import UIKit
 
final class TabBarController: UITabBarController {
    
    // MARK: - Pablic Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        _ = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tab_editorial_active"), selectedImage: nil)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tab_profile_active"), selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
