//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by ulyana on 17.02.25.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let profileViewController = ProfileViewController()
        let profileViewPresenterSpy = ProfileViewPresenterSpy()
        profileViewController.presenter = profileViewPresenterSpy
        profileViewPresenterSpy.view = profileViewController
        
        //when
        _ = profileViewController.view
        
        //then
        XCTAssertTrue(profileViewPresenterSpy.viewDidLoadCalled)
    }
    
    func testViewControllerCallsDidUpdateProfileDetails() {
        //given
        let profileViewController = ProfileViewController()
        let profileViewPresenterSpy = ProfileViewPresenterSpy()
        profileViewController.presenter = profileViewPresenterSpy
        profileViewPresenterSpy.view = profileViewController
        
        //when
        profileViewController.updateProfileDetails()
        
        //then
        XCTAssertTrue(profileViewPresenterSpy.didUpdateProfileDetailsCalled)
    }
    
    func testViewControllerCallsDidUpdateAvatar() {
        //given
        let profileViewController = ProfileViewController()
        let profileViewPresenterSpy = ProfileViewPresenterSpy()
        profileViewController.presenter = profileViewPresenterSpy
        profileViewPresenterSpy.view = profileViewController
        
        //when
        profileViewController.updateAvatar()
        
        //then
        XCTAssertTrue(profileViewPresenterSpy.didUpdateAvatarCalled)
    }
}
