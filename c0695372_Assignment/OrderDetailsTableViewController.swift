//
//  OrderDetailsTableViewController.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-24.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit

class OrderDetailsTableViewController: UITableViewController {
    
    var items = [OrderItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 98.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
        
        let cell = UINib(nibName: CartCellIdentifiers.cartCell, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: CartCellIdentifiers.cartCell)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartCellIdentifiers.cartCell, for: indexPath) as! CartCell
        
        let item = items[indexPath.row]
        
        let url = URL(string: item.productImageUrl)!
        cell.downloadTask = cell.productImageView.loadImage(url: url)
        
        cell.productNameLabel.text = item.productName
        cell.quantityLabel.text = "\(Int(item.quantity))"
        cell.unitPriceLabel.text = String(format: "%.2f", item.unitPrice)
        
        let total = item.unitPrice * Double(item.quantity)
        cell.totalLabel.text = String(format: "%.2f", total)

        return cell
    }
    
}
