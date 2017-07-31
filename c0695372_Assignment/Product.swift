//
//  Product.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-17.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import Foundation

struct Product {
    
    let key: String
    let name: String
    let categoryName: String
    let price: Double
    let imageUrl: String
    
    init(name: String, categoryName: String, price: Double, imageUrl: String, key: String = "") {
        self.key = key
        self.name = name
        self.categoryName = categoryName
        self.price = price
        self.imageUrl = imageUrl
    }
    
}
