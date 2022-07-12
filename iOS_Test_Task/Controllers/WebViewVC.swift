//
//  WebViewVC.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 12.07.2022.
//

import UIKit
import WebKit

class WebViewVC: UIViewController {
    
    let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hidesBarsOnTap = true
        view.addSubview(webView)
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    func setupConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func loadRequest(urlString: String) {
        
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url)
        
        webView.load(urlRequest)
    }
}
