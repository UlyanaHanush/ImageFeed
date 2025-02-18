//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by ulyana on 16.02.25.
//

import Foundation
import ImageFeed

final class WebViewViewControllerSpy: WebViewControllerProtocol {
    var loadRequestCalled: Bool = false
    
    var presenter: WebViewPresenterProtocol?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
}
