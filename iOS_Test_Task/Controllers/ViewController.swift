//
//  ViewController.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 30.06.2022.
//

import UIKit

final class ViewController: UIViewController {
    
    var loadingView: LoadingReusableView?

    var isLoading = false
    
    var imagesResults: [ImagesResult] = []
//    var imagesArray = [ImagesResult]()
    
    private let searchBar = UISearchBar()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.register(LoadingReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "spinner")
        
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboard()
        //        self.title = "Photos"
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupConstraints()
//        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
        //        self.navigationController?.navigationBar.isHidden = false
        //        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
    
//    func loadData() {
//        isLoading = false
//        collectionView.collectionViewLayout.invalidateLayout()
//        for _ in 0...20 {
//            imagesArray += imagesResults
//        }
//        self.collectionView.reloadData()
//    }
    
    func fetchPhotos(query: String) {
        
        let apiKey = "e0ad4be925e58c57030f8f0d4683f9f4096eebf8951c4b8716f6e9a63ccf9539"
        let numberOfPages = 3
        let urlStrings = Array(0..<numberOfPages).map { "https://serpapi.com/search.json?q=\(query)&tbm=isch&ijn=\($0)&api_key=\(apiKey)"
        }
        
        urlStrings.compactMap { URL(string: $0) }.forEach { url in
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self = self,
                      let data = data,
                      error == nil else { return }
                
                do {
                    let jsonResult = try JSONDecoder().decode(ImagesModel.self, from: data)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.collectionView.collectionViewLayout.invalidateLayout()
                        for _ in 0...20 {
                            self.imagesResults += jsonResult.imagesResults
                        }
                        self.collectionView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
            .resume()
        }
    }
    
    func pushView(viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        self.view.window!.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

// MARK: - extension for collection view

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        if let imageURLString = URL(string: imagesResults[indexPath.row].thumbnail) {
            cell.imageView.loadImage(url: imageURLString)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == imagesResults.count - 20, !self.isLoading {
            loadMoreData()
        }
    }

    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            let start = imagesResults.count
            let end = start + 20
            
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
                for _ in start...end {
//                    self.imagesResults += self.imagesResults
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.isLoading = false
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PhotoVC()
        if let url = URL(string: imagesResults[indexPath.row].original) {
            vc.imageView.loadImage(url: url)
        }
        pushView(viewController: vc)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.isLoading {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 55)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width/2  - 1
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "spinner", for: indexPath) as! LoadingReusableView
            loadingView = aFooterView
            loadingView?.backgroundColor = UIColor.clear
            return aFooterView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicator.startAnimating()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicator.stopAnimating()
        }
    }
    
}


// MARK: - extension for search bar

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text?.replacingOccurrences(of: " ", with: "%20") {
            imagesResults = []
            
            fetchPhotos(query: text)
//            loadData()
            collectionView.reloadData()
        }
    }
}

extension UIViewController {
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target:self, action:    #selector(UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}
