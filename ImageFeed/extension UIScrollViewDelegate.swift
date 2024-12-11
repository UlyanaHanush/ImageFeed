//
//  extension UIScrollViewDelegate.swift
//  ImageFeed
//
//  Created by ulyana on 5.12.24.
//

import Foundation
import UIKit

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollViewAfterZoom()
    }
}
