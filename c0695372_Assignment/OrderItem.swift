//
//  OrderItem.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-24.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import Foundation

struct OrderItem {
    
    let productId: String
    let productName: String
    let productImageUrl: String
    let unitPrice: Double
    let quantity: Int32
    
    init(productId: String, productName: String, productImageUrl: String, unitPrice: Double, quantity: Int32) {
        self.productId = productId
        self.productName = productName
        self.productImageUrl = productImageUrl
        self.unitPrice = unitPrice
        self.quantity = quantity
    }
    
}
