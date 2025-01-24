//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by ulyana on 4.12.24.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Private Properties
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var backButtonSingleImageView: UIButton = {
        let button = UIButton(type: .custom)
        
        let imageButton = UIImage(named: "backward")
        button.setImage(imageButton , for: .normal)
        
        button.addTarget(nil, action: #selector(didTapBackButton(_:)), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var saveButtonSingleImageView: UIButton = {
        let button = UIButton(type: .custom)
        
        let imageButton = UIImage(named: "share_button")
        button.setImage(imageButton , for: .normal)
        
        button.addTarget(nil, action: #selector(didTapSaveButton(_:)), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        addSubviews()
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - IBAction
    
    @IBAction private  func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapSaveButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func addSubviews() {
        view.backgroundColor = .ypBlack
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)

        view.addSubview(saveButtonSingleImageView)
        view.addSubview(backButtonSingleImageView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButtonSingleImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            backButtonSingleImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButtonSingleImageView.heightAnchor.constraint(equalToConstant: 48),
            backButtonSingleImageView.widthAnchor.constraint(equalToConstant: 48),
            
            scrollView.trailingAnchor.constraint(equalTo: super.view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: super.view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: super.view.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: super.view.topAnchor),
            
            saveButtonSingleImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            saveButtonSingleImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButtonSingleImageView.heightAnchor.constraint(equalToConstant: 50),
            saveButtonSingleImageView.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    private func centerImageInScrollViewAfterZoom() {
        let xInset = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let yInset = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        // форсирует пересчет вью
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        // Вызов функции не меняет scrollView.contentSize.
        // Помечает, что данные лэйаута устарели, и что при следующей итерации лэйаута экрана значение scale будет считано и применено к содержимому.
        scrollView.setZoomScale(scale, animated: false)
        // форсирует пересчет фреймов
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollViewAfterZoom()
    }
}
