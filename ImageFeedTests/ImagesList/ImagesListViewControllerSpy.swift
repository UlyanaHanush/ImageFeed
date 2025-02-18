//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by ulyana on 17.02.25.
//

import Foundation
import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var didUpdateTableViewAnimatedCalled: Bool = false
    
    var presenter: ImagesListViewPresenterProtocol?
    
    var oldCount: Int = 0
    
    var newCount: Int = 0
    
    func updateTableViewAnimated() {
        didUpdateTableViewAnimatedCalled = true
    }
}
