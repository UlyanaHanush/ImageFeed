//
//  ViewController.swift
//  ImageFeed
//
//  Created by ulyana on 22.11.24.
//

import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    var oldCount: Int { get set }
    var newCount: Int { get set }
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - Public Properties
    
    var presenter: ImagesListViewPresenterProtocol?
    var oldCount: Int = 0
    var newCount: Int = 0
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = {
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
        
        
        presenter?.viewDidLoad()
        addSubviews()
    }
    
    // MARK: - Public Methods
    
    func updateTableViewAnimated() {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    // MARK: - Private Methods
    
    private func showSingleImage(indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        singleImageViewController.imageObject = presenter?.photos[indexPath.row]
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true, completion: nil)
    }

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
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    /// количество ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
     
    /// создание и переиспользование ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        if let imageListCell = cell as? ImagesListCell {
            configCell(for: imageListCell, with: indexPath)
            return imageListCell
        } else {
            return UITableViewCell()
        }
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
        guard let photo = presenter?.photos[indexPath.row] else { return 0 }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if ProcessInfo.processInfo.environment["isUITest"] == "true" { return }
        
        guard let photo = presenter?.photos else { return }
        if indexPath.row + 1 == photo.count {
            presenter?.loadImages()
        }
    }
}

// MARK: - Extension

extension ImagesListViewController {
    func getImageForIndexPath(_ indexPath: IndexPath) -> UIImage? {
           guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return nil }
           return cell.cellImage.image
       }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.delegate = self
        
        guard let photo = presenter?.photos[indexPath.row] else { return }
        let url = URL(string: photo.thumbImageURL)
            
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "plugOnLoading")) { result in
            switch result {
            case .success:
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print("[ImagesListViewController]:[configCell]\(error.localizedDescription)")
            }
        }
        
        if let photoCreatedAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: photoCreatedAt)
        }
        
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let photo = presenter?.photos[indexPath.row] else { return }
        
        UIBlockingProgressHUD.show()
        
        presenter?.didChangeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(_):
                guard let photo = presenter?.photos[indexPath.row] else { return }
                cell.setIsLiked(photo.isLiked)
            case .failure(_):
                self.showAlert()
            }
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default) { _ in }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}

