//
//  ImagesListViewTests.swift
//  ImageFeedTests
//
//  Created by ulyana on 17.02.25.
//

import XCTest
@testable import ImageFeed

final class ImagesListViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let imagesListViewController = ImagesListViewController()
        let imagesListViewPresenterSpy = ImagesListViewPresenterSpy()
        imagesListViewPresenterSpy.view = imagesListViewController
        imagesListViewController.presenter = imagesListViewPresenterSpy
        
        //when
        _ = imagesListViewController.view
        
        //then
        XCTAssertTrue(imagesListViewPresenterSpy.viewDidLoadCalled)
    }
    
    func testViewControllerCounts() {
        //given
        let imagesListViewController = ImagesListViewController()
        let imagesListViewPresenter = ImagesListViewPresenter()
        imagesListViewPresenter.view = imagesListViewController
        imagesListViewController.presenter = imagesListViewPresenter
        
        //when
        imagesListViewPresenter.viewDidLoad()
        
        //then
        XCTAssertLessThanOrEqual(imagesListViewController.oldCount, imagesListViewController.newCount)
    }
    
    func testPresenterCallsUpdateTableViewAnimated() {
        //given
        let imagesListServiceSpy = ImagesListServiceSpy()
        let imagesListViewControllerSpy = ImagesListViewControllerSpy()
        let imagesListViewPresenter = ImagesListViewPresenter()
        imagesListViewPresenter.view = imagesListViewControllerSpy
        imagesListViewControllerSpy.presenter = imagesListViewPresenter
        imagesListViewPresenter.imagesListService = imagesListServiceSpy 
        
        //when
        let photo = Photo(
                        id: "",
                        size: CGSize(),
                        createdAt: nil,
                        welcomeDescription: nil,
                        thumbImageURL: "",
                        largeImageURL: "",
                        isLiked: false
                    )
        var photos = [photo]
        imagesListViewPresenter.photos = photos
        imagesListViewPresenter.didUpdateTableViewAnimated()
        
        //then
        XCTAssertTrue(imagesListViewControllerSpy.didUpdateTableViewAnimatedCalled)
    }
    
    func testPresenterCallsFetchPhotosNextPage() {
        //given
        let imagesListViewPresenter = ImagesListViewPresenter()
        let imagesListServiceSpy = ImagesListServiceSpy()
        imagesListViewPresenter.imagesListService = imagesListServiceSpy
        
        //when
        imagesListViewPresenter.loadImages()
        
        //then
        XCTAssertTrue(imagesListServiceSpy.fetchPhotosNextPageCalled)
    }
    
    func testPresenterViewDidLoadCallsFetchPhotosNextPage() {
        //given
        let imagesListViewPresenter = ImagesListViewPresenter()
        let imagesListServiceSpy = ImagesListServiceSpy()
        imagesListViewPresenter.imagesListService = imagesListServiceSpy
        
        //when
        imagesListViewPresenter.viewDidLoad()
        
        //then
        XCTAssertTrue(imagesListServiceSpy.fetchPhotosNextPageCalled)
    }
}
