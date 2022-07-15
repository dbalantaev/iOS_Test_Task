//
//  WebViewVC.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 12.07.2022.
//

import UIKit
import WebKit

final class WebViewVC: UIViewController {
    var sourceURL = String()
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    private lazy var closeBtn: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        return button
    }()
    @objc func closeBtnTapped () {
        self.dismissView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        view.addSubview(closeBtn)
        setupConstraints()
        loadRequest()
    }
    private func setupConstraints() {
        closeBtn.frame = CGRect(x: 20, y: 80, width: 25, height: 25)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func loadRequest() {
        let url = sourceURL
        guard let url = URL(string: url) else { return }
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
}
