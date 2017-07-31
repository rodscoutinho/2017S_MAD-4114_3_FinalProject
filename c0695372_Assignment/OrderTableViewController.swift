//
//  OrderTableViewController.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-24.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FBSDKLoginKit

struct OrderTableCellIdentifiers {
    static let orderTableViewCell = "OrderTableViewCell"
}

class OrderTableViewController: UITableViewController {
    
    fileprivate var orders = [Order]()
    fileprivate var ref: DatabaseReference!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        return formatter
    }()
    
    let dateFormatterToShow: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        ref = Database.database().reference()
        
        let cell = UINib(nibName: OrderTableCellIdentifiers.orderTableViewCell, bundle: nil)
        self.tableView.register(cell, forCellReuseIdentifier: OrderTableCellIdentifiers.orderTableViewCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchOrders()
    }
    
    private func fetchOrders() {
        
        ref.child("order").queryOrdered(byChild: "uid").queryEqual(toValue: FBSDKAccessToken.current().userID!).observe(.value, with: { (snapshot: DataSnapshot) in
            
            if let value = snapshot.value as? NSDictionary {
                self.orders = [Order]()
                
                let ordersDict = value as! [String: Any]
                
                for (key, value) in ordersDict {
                    print(key, value)
                    let orderDetails = value as! [String: Any]
                   
                    var orderDate = Date()
                    if let date = self.dateFormatter.date(from: orderDetails["date"] as! String) {
                        orderDate = date
                    }
                    
                    let itemsDict = orderDetails["items"] as! [String: Any]
                    var items = [OrderItem]()
                    for (key, value) in itemsDict {
                        
                        let itemDetails = value as! [String: Any]
                        
                        let orderItem = OrderItem(productId: key,
                                                  productName: itemDetails["productName"] as! String,
                                                  productImageUrl: itemDetails["productImageUrl"] as! String,
                                                  unitPrice: itemDetails["unitPrice"] as! Double,
                                                  quantity: itemDetails["quantity"] as! Int32)
                        
                        items.append(orderItem)
                    }
                    
                    self.orders.append(Order(date: orderDate, items: items))
                    
                }
                
                self.orders.sort(by: { (lhs, rhs) -> Bool in
                    lhs.date > rhs.date
                })
                
            }
            
            self.tableView.reloadData()
            
        })
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showOrderDetails" {
            
            let indexPath = sender as! IndexPath
            
            let order = orders[indexPath.row]
            
            let orderDetailsTableViewController = segue.destination as! OrderDetailsTableViewController
            orderDetailsTableViewController.items = order.items
            
        }
        
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderTableCellIdentifiers.orderTableViewCell, for: indexPath) as! OrderTableViewCell
        
        let order = self.orders[indexPath.row]
        
        var total = 0.0
        var numberOfItems: Int32 = 0
        for item in order.items {
            total += Double(item.quantity) * item.unitPrice
            numberOfItems += item.quantity
        }
        
        cell.orderDateLabel.text = dateFormatterToShow.string(from: order.date)// dateFormatter.string(from: order.date)
        if numberOfItems == 1 {
            cell.numberOfItemsLabel.text = "\(numberOfItems) product"
        } else {
            cell.numberOfItemsLabel.text = "\(numberOfItems) products"
        }
        cell.totalLabel.text = String(format: "%.2f", total)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showOrderDetails", sender: indexPath)
        
    }
    
}





























