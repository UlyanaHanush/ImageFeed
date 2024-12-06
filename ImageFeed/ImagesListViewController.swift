//
//  ViewController.swift
//  ImageFeed
//
//  Created by ulyana on 22.11.24.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - Constants
    
    let photosName: [String] = Array(0..<20).map{ "\($0)" }
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - Public Properties
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - IBOutlet

    @IBOutlet private var tableView: UITableView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

