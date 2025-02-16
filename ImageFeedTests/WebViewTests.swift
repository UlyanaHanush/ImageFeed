//
//  WebViewTests.swift
//  ImageFeedTests
//
//  Created by ulyana on 22.11.24.
//

import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let webViewViewController = WebViewViewController()
        let webViewPresenterSpy = WebViewPresenterSpy()
        webViewViewController.presenter = webViewPresenterSpy
        webViewPresenterSpy.view = webViewViewController
        
        //when
        _ = webViewViewController.view
        
        //then
        XCTAssertTrue(webViewPresenterSpy.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let webViewViewControllerSpy = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewPresenter.view = webViewViewControllerSpy
        webViewViewControllerSpy.presenter = webViewPresenter
        
        //when
        webViewPresenter.viewDidLoad()
        
        //then
        XCTAssertTrue(webViewViewControllerSpy.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = webViewPresenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1
        
        //when
        let shouldHideProgress = webViewPresenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let authConfiguration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: authConfiguration)
        
        //when
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        //then
        XCTAssertTrue(urlString.contains(authConfiguration.authURLString))
        XCTAssertTrue(urlString.contains(authConfiguration.accessKey))
        XCTAssertTrue(urlString.contains(authConfiguration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(authConfiguration.accessScope))
    }
    
    func testCodeFromURL() {
        //given
        guard var urlComponents =  URLComponents(string: "https://unsplash.com/oauth/authorize/native") else {
            XCTFail("urlComponents is nil")
            return
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        
        guard let url = urlComponents.url else {
            XCTFail("url is nil")
            return
        }
        
        let authHelper = AuthHelper()
        
        //when
        let code = authHelper.code(from: url)
        
        XCTAssertEqual(code, "test code")
    }
}

