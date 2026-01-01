//
//  Car.swift
//  CarGallery
//
//  Created by Yigithan Ozyurt on 31.12.2025.
//

import Foundation

struct Car: Codable {
    let id: Int
    let brand: String
    let model: String
    let year: Int
    let color: String
    let price: Int
    let fuelType: String
    let images: [String]
}

class FavoriteManager {
    static let shared = FavoriteManager()
    var favorites: [Car] = []
    
    func add(_ car: Car) {
        if !favorites.contains(where: { $0.id == car.id }) {
            favorites.append(car)
        }
    }
    
    func remove(_ car: Car) {
        favorites.removeAll(where: { $0.id == car.id })
    }
    
    func isFavorite(_ car: Car) -> Bool {
        return favorites.contains(where: { $0.id == car.id })
    }
}
