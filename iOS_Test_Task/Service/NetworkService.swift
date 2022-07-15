//
//  NetworkService.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 30.06.2022.
//

import UIKit

class NetworkService {
    
    // MARK: загрузка изображений и кэширование
    
    var imageCache = NSCache<AnyObject, AnyObject>()
    
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
