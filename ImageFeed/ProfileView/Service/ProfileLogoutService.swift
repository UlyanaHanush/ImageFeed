//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by ulyana on 6.02.25.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    // MARK: - Singleton
    
    static let shared = ProfileLogoutService()
    private init() { }
    
    // MARK: - Public Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileLogoutProviderDidChange")
    
    // MARK: - Private Properties
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Public Methods
    
    func logout() {
        cleanCookies()
        cleanUserData()
        
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }

    // MARK: - Private Methods
    
    private func cleanCookies() {
       // Очищаем все куки из хранилища
       HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
       // Запрашиваем все данные из локального хранилища
       WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          // Массив полученных записей удаляем из хранилища
          records.forEach { record in
             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
          }
       }
    }
    
    private func cleanUserData() {
        OAuth2TokenStorage().token = nil
        profileService.cleanProfile()
        profileImageService.cleanAvatar()
        imagesListService.cleanImagesList()
    }
}
    
