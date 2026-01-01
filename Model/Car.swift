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
