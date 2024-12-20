//
//  extension UITableViewDataSource.swift
//  ImageFeed
//
//  Created by ulyana on 28.11.24.
//

import Foundation
import UIKit

extension ImagesListViewController: UITableViewDataSource {
    
    /// количество ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
     
    /// создание и переиспользование ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
