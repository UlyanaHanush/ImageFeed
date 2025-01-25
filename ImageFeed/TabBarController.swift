//
//  TabBarController.swift
//  ImageFeed
//
//  Created by ulyana on 21.01.25.
//

import UIKit
 
final class TabBarController: UITabBarController {
    
    // MARK: - UIViewController(*)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        
        tabBar.barTintColor = .ypBlack
        tabBar.tintColor = .ypWhite
    }
    
    // MARK: - Private Methods
    
    private func setupTabBar() {
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tab_editorial_active"), selectedImage: nil)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tab_profile_active"), selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
