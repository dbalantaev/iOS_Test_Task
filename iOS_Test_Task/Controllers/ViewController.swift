//
//  ViewController.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 30.06.2022.
//

import UIKit

class ViewController: UIViewController {
    
//    var loadingView: LoadingReusableView?
//
//    var isLoading = false
    
    var imagesResults: [ImagesResult] = []
    
    var images = [UIImage]()
    
    var networkService = NetworkService()
    
    private var image: UIImage? {
        didSet {
            images.append(image!)
            hideLoadingProcess()
            didRecieveSearchResult()
        }
    }
    
    private let searchController = UISearchController()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 4
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
//        cv.register(LoadingReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "spinner")
//
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        return cv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = .systemBackground
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboard()
        self.title = "Photos"
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: 10, y: 0, width: view.frame.size.width-20, height: view.frame.size.height)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
                activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
        
    }
    
    private func showLoadingProcess() {
        activityIndicator.startAnimating()
        collectionView.isHidden = true
    }
    
    private func didRecieveSearchResult() {
        collectionView.reloadData()
    }
    
    private func hideLoadingProcess() {
        activityIndicator.stopAnimating()
        collectionView.isHidden = false
    }
    
    func fetchPhotos(query: String) {
        
        let apiKey = "82247a1f4c90bd2a9b0f546c2d276b684b1dc5d9ef7f5ec956e919b93d1d8fbd"
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
                        self.imagesResults += jsonResult.imagesResults
                        self.networkService.loadImage(array: self.imagesResults) { image in
                            self.image = image
                        }
                    }
                } catch {
                    print(error)
                }
            }.resume()
        }
    }
    
}

// MARK: - extension Collection View

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PhotoVC()
        vc.selectedImage = indexPath.row
        vc.images = images
        vc.sourceURL = imagesResults[indexPath.row].link
        pushView(viewController: vc)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width/2 - 4
        
        return CGSize(width: width, height: width)
    }
    
    // MARK: Пагинация (не работает, тк API не позволяет ее сделать (там просто нет для нее параметров))

//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == images.count - 20, !self.isLoading {
//            loadMoreData()
//        }
//    }
//
//    func loadMoreData() {
//            if !self.isLoading {
//                self.isLoading = true
//                DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { // Remove the 1-second delay if you want to load the data without waiting
//                    // Download more data here
//
//
//                    DispatchQueue.main.async {
//                        self.didRecieveSearchResult()
//                        self.isLoading = false
//                    }
//                }
//            }
//        }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        if self.isLoading {
//            return CGSize.zero
//        } else {
//            return CGSize(width: collectionView.bounds.size.width, height: 55)
//        }
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionFooter {
//            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "spinner", for: indexPath) as! LoadingReusableView
//            loadingView = aFooterView
//            loadingView?.backgroundColor = UIColor.clear
//            return aFooterView
//        }
//        return UICollectionReusableView()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//        if elementKind == UICollectionView.elementKindSectionFooter {
//            self.loadingView?.activityIndicator.startAnimating()
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
//        if elementKind == UICollectionView.elementKindSectionFooter {
//            self.loadingView?.activityIndicator.stopAnimating()
//        }
//    }

}


// MARK: - extension for search bar

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text?.replacingOccurrences(of: " ", with: "%20") {
            imagesResults = []
            images = []
            fetchPhotos(query: text)
            didRecieveSearchResult()
            showLoadingProcess()
        }
    }
}
