//
//  FavoriteManager.swift
//  CarGallery
//
//  Created by Yigithan Ozyurt on 1.01.2026.
//

import UIKit
import CoreData

class FavoriteManager {
    static let shared = FavoriteManager()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func getAllFavorites() -> [FavoriteCar] {
        let request: NSFetchRequest<FavoriteCar> = FavoriteCar.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

    func add(_ car: Car) {
        let newFav = FavoriteCar(context: context)
        newFav.id = Int64(car.id)
        newFav.brand = car.brand
        newFav.model = car.model
        newFav.color = car.color
        newFav.price = Int64(car.price)
        newFav.year = Int64(car.year)
        newFav.fuelType = car.fuelType
        
        if let encodedImages = try? JSONEncoder().encode(car.images) {
            newFav.image = String(data: encodedImages, encoding: .utf8)
        }
        saveContext()
    }

    func remove(_ carID: Int) {
        let request: NSFetchRequest<FavoriteCar> = FavoriteCar.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", carID)
        if let results = try? context.fetch(request) {
            results.forEach { context.delete($0) }
            saveContext()
        }
    }

    func isFavorite(_ carID: Int) -> Bool {
        let request: NSFetchRequest<FavoriteCar> = FavoriteCar.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", carID)
        return (try? context.count(for: request)) ?? 0 > 0
    }

    private func saveContext() {
        if context.hasChanges { try? context.save() }
    }
}
