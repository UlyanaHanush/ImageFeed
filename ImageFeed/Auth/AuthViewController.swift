//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by ulyana on 18.12.24.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController // segue.destination переход между контроллерами
            else {
                // всегда крашит приложение
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    /// задает кнопку "Назад" при авторизации
    private func configureBackButton() {
        // задаём изображение, которое используется на экране
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        // ещё раз устанавливаем это изображение, чтобы система могла правильно отобразить анимацию перехода между экранами
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        //  Создаём кнопку типа UIBarButtonItem с пустым заголовком
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: process code
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
