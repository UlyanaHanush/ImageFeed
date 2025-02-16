//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by ulyana on 16.02.25.
//

import Foundation
import WebKit

public protocol WebViewPresenterProtocol {
    var view: WebViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: WebViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    // MARK: - Initializers
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: - Public Methods
    
    /// направляет пользователя на страницу авторизации
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    /// функция code(from:) возвращает код авторизации, если он получен
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    // MARK: - Private Methods
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
