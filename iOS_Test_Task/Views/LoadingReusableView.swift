//
//  LoadingReusableView.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 07.07.2022.
//

import UIKit

class LoadingReusableView: UICollectionReusableView {
    
    let identifier = "spinner"

   var activityIndicator = UIActivityIndicatorView()

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addSubview(activityIndicator)
//        activityIndicator.color = UIColor.white
//        
//        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
