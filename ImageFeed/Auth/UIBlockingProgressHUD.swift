//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by ulyana on 9.01.25.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
    // MARK: - Private Properties
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    // MARK: - Public Methods
    
    /// блокирует пользовательское взаимодействие
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    /// разблокирует пользовательского взаимодействия
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
