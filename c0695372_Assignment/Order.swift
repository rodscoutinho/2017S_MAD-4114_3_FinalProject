//
//  Order.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-24.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import Foundation

struct Order {
    
    let date: Date
    let items: [OrderItem]
    
    init(date: Date, items: [OrderItem]) {
        self.date = date
        self.items = items
    }
    
}
