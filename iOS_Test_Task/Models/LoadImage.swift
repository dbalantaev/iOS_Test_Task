//
//  LoadImage.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 30.06.2022.
//

//import UIKit
//
//struct LoadedImage {
//    var loadedImage = [UIImage]()
//}
//
//class LoadImage: UIImageView {
//    
//    var task: URLSessionDataTask!
//    var imageCache = NSCache<AnyObject, AnyObject>()
//    
//    var images = LoadedImage()
//    
//    func loadImage(url: URL) {
//        image = nil
//        
//        if let task = task {
//            task.cancel()
//        }
//        
//        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
//            self.image = imageFromCache
//            return
//        }
//        
//        task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            guard let data = data,
//                  let newImage = UIImage(data: data) else {
//                      print("Error load image: \(url)")
//                      return
//                  }
//            
//            self?.imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
//            DispatchQueue.main.async {
//                self?.image = newImage
//                self?.images.loadedImage.append(newImage)
//                
//            }
//        }
//        task.resume()
//    }
//}
