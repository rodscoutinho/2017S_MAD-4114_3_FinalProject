//
//  CartViewController.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-20.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit
import FirebaseDatabase

struct CartCellIdentifiers {
    static let cartEmptyCell = "CartEmptyCell"
    static let cartCell = "CartCell"
}

class CartViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var placeOrderButton: UIBarButtonItem!
    @IBOutlet var editCartButton: UIBarButtonItem!
    
    fileprivate var items = [Cart]()
    private var ref: DatabaseReference!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeOrderButton.isEnabled = false
        
        self.ref = Database.database().reference()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        tableView.estimatedRowHeight = 98.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        var cell = UINib(nibName: CartCellIdentifiers.cartEmptyCell, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: CartCellIdentifiers.cartEmptyCell)
        
        cell = UINib(nibName: CartCellIdentifiers.cartCell, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: CartCellIdentifiers.cartCell)
        
        totalLabel.text = ""
        
        editCartButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cart")
        
        do {
            if let items = try managedContext.fetch(fetchRequest) as? [Cart] {
                self.items = items
                updateTotal()
                tableView.reloadData()
            }
            
            print(items)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    fileprivate func updateTotal() {
        
        if items.count == 0 {
            totalLabel.text = "Your cart is empty"
            editCartButton.isEnabled = false
            tableView.isEditing = false
            editCartButton.title = "Edit"
            placeOrderButton.isEnabled = false
            return
        }
        
        editCartButton.isEnabled = true
        placeOrderButton.isEnabled = true
        
        var sum = 0.0
        for item in items {
            sum += item.unitPrice * Double(item.quantity)
        }
        totalLabel.text = String(format: "%.2f", sum)
        
    }
    
    @IBAction func placeOrder(_ sender: UIBarButtonItem) {
        
        var itemsToSave = [String: Any]()
        
        for item in items {
            let details: [String: Any] = [
                "productImageUrl": item.productImageUrl!,
                "productName": item.productName!,
                "quantity": item.quantity,
                "unitPrice": item.unitPrice
            ]
            
            itemsToSave[item.productId!] = details
        }
        
        let order: [String: Any] = [
                     "uid" : FBSDKAccessToken.current().userID!,
                     "date" : dateFormatter.string(from: Date()),
                     "items": itemsToSave
        ]
        
        self.ref.child("order").childByAutoId().setValue(order)
        
        deleteCart()
        
        
        let alertController = UIAlertController(title: "Order created successfully", message: "Your order has been placed.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            self.tabBarController?.selectedIndex = 0
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func deleteCart() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        
        
        do {
            try managedContext.execute(request)
            items.removeAll()
            tableView.reloadData()
            updateTotal()
        } catch {
            // Error Handling
        }
        
    }
    
    @IBAction func editCart(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing {
            editCartButton.title = "Done"
        } else {
            editCartButton.title = "Edit"
        }
    }
    
}

extension CartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
        
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let itemToRemove = items[indexPath.row]
        
            let managedContext = appDelegate.persistentContainer.viewContext
            
            managedContext.delete(itemToRemove)
            items.remove(at: indexPath.row)
            
            do {
                try managedContext.save()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                updateTotal()
            } catch let error as NSError {
                print("Saving error: \(error), description: \(error.userInfo)")
            }
        
        }
        
    }
    
}

extension CartViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if items.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CartCellIdentifiers.cartEmptyCell, for: indexPath)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        
        let item = items[indexPath.row]
        
        if let productImageUrl = item.productImageUrl {
            let url = URL(string: productImageUrl)!
            cell.downloadTask = cell.productImageView.loadImage(url: url)
        }
        
        cell.productNameLabel.text = item.productName
        cell.quantityLabel.text = "\(Int(item.quantity))"
        cell.unitPriceLabel.text = String(format: "%.2f", item.unitPrice)
        
        let total = item.unitPrice * Double(item.quantity)
        cell.totalLabel.text = String(format: "%.2f", total)
        
        return cell
    }
    
    
}



































