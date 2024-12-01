//
//  ViewController.swift
//  ImageFeed
//
//  Created by ulyana on 22.11.24.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

