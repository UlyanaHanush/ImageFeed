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
    let imagesListService = ImagesListService()
    
    // MARK: - Public Properties
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Private Properties
    
    lazy var tableView: UITableView = {
        tableView = UITableView()
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
    }
    
    // MARK: -Private Methods
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.backgroundColor = .ypBlack
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: super.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: super.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: super.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: super.view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    func showSingleImage(indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()

        let image = UIImage(named: photosName[indexPath.row])
        singleImageViewController.image = image
        
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

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

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    /// переход от таблице к одной картинке
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImage(indexPath: indexPath)
    }

    /// просчет высоты ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: - Extension

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())

        let isLiked = indexPath.row % 2 == 0
        
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage(<#Int#>, completion: <#(Result<Profile, any Error>) -> Void#>)
        }
    }
}
