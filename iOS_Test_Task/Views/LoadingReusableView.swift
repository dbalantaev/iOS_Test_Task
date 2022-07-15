//
//  LoadingReusableView.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 07.07.2022.
//

//import UIKit
//
// MARK:  Ячейка с индикатором для пагинации
//
//class LoadingReusableView: UICollectionReusableView {
//
//    let activityIndicator: UIActivityIndicatorView = {
//        let indicator = UIActivityIndicatorView()
//        indicator.style = .medium
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        indicator.backgroundColor = .systemBackground
//        return indicator
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//            addSubview(activityIndicator)
//        activityIndicator.backgroundColor = .green
//        setupConstraints()
//    }
//    
//    func setupConstraints() {
//        NSLayoutConstraint.activate(
//            [
//                activityIndicator.topAnchor.constraint(equalTo: topAnchor),
//                activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
//                activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
//                activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
//            ]
//        )
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
