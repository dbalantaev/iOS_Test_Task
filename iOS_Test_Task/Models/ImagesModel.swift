//
//  ImagesModel.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 06.07.2022.
//

import Foundation

// MARK: - ImagesModel
struct ImagesModel: Codable {
    let imagesResults: [ImagesResult]
//    let suggestedSearches: [SuggestedSearch]

    enum CodingKeys: String, CodingKey {
        case imagesResults = "images_results"
//        case suggestedSearches = "suggested_searches"
    }
}

// MARK: - ImagesResult
struct ImagesResult: Codable {
//    let position: Int
    let thumbnail, original, title: String
    let link: String
    let source: String
//    let isProduct: Bool
//    let inStock: Bool

    enum CodingKeys: String, CodingKey {
//        case position = "position"
        case thumbnail, original, title, link, source
//        case isProduct = "is_product"
//        case inStock = "in_stock"
    }
}
