//
//  NetworkService.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 30.06.2022.
//

import UIKit

final class NetworkService {
    var imageCache = NSCache<AnyObject, AnyObject>()
    func fetchPhotos(query: String, completion: @escaping ([ImagesResult]) -> Void) {
        let apiKey = "20886cf384c56470133e96619b70e1e2e01d1cb11e929d7ee1069defe1e43438"
        let numberOfPages = 3
        let urlStrings = Array(0..<numberOfPages).map {
            "https://serpapi.com/search.json?q=\(query)&tbm=isch&ijn=\($0)&api_key=\(apiKey)"
        }
        urlStrings.compactMap { URL(string: $0) }.forEach { url in
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data,
                      error == nil else { return }
                do {
                    let jsonResult = try JSONDecoder().decode(ImagesModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(jsonResult.imagesResults)
                    }
                } catch {
                    print(error)
                }
            }.resume()
        }
    }
    func loadImage(array: [ImagesResult], completion: @escaping (UIImage?) -> Void) {
        for elem in array {
            if let imageFromCache = imageCache.object(forKey: elem.thumbnail as AnyObject) as? UIImage {
                completion(imageFromCache)
                return
            } else {
                guard let url = URL(string: elem.thumbnail) else { return }
                URLSession.shared.dataTask(with: url) { data, _, error in
                    guard let data = data, error == nil else { return }
                    guard let image = UIImage(data: data) else { return }
                    self.imageCache.setObject(image, forKey: elem.thumbnail as AnyObject )
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }.resume()
            }
        }
    }
}
