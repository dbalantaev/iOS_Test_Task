//
//  MainVC.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 30.06.2022.
//

import UIKit

final class MainVC: UIViewController {

    var imagesResults: [ImagesResult] = []
    var images = [UIImage]()
    var networkService = NetworkService()

    private var imageURL: [ImagesResult]? {
        didSet {
            self.imagesResults = imageURL!
            self.networkService.loadImage(array: self.imagesResults) { [weak self] image in
                self?.image = image
            }
        }
    }
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
        let collview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collview.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collview.translatesAutoresizingMaskIntoConstraints = false
        collview.backgroundColor = .systemBackground
        return collview
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

    private func setupConstraints() {
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

}
// MARK: - extension Collection View

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                            for: indexPath) as? CollectionViewCell
        else { return UICollectionViewCell() }
        cell.imageView.image = images[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let photoVC = PhotoVC()
        photoVC.selectedImage = indexPath.row
        photoVC.images = images
        photoVC.sourceURL = imagesResults[indexPath.row].link
        pushView(viewController: photoVC)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width/2 - 4
        return CGSize(width: width, height: width)
    }

}
// MARK: - extension for search bar

extension MainVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text?.replacingOccurrences(of: " ", with: "%20") {
            imagesResults = []
            images = []
            networkService.fetchPhotos(query: text) { [weak self] jsonResult in
                self?.imageURL = jsonResult
            }
            didRecieveSearchResult()
            showLoadingProcess()
        }
    }

}
