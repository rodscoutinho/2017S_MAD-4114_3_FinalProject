//
//  ProductDetailTableViewController.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-19.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit
import CoreData

class ProductDetailTableViewController: UITableViewController {

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var quantityStepper: UIStepper!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var unitPriceLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    
    var product: Product?
    var productImage: UIImage?
    private let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        productImageView.addSubview(activityIndicator)
        activityIndicator.center = productImageView.center
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        tableView.tableFooterView = UIView()
        
        if let product = product {
            
            downloadProductImage(product.imageUrl)
            
            productNameLabel.text = product.name
            categoryLabel.text = product.categoryName
            quantityLabel.text = "1"
            unitPriceLabel.text = String(format: "%.2f", product.price)
            totalLabel.text =  String(format: "%.2f", product.price)
            
        }
    }
    
    @IBAction func addProductToCart(_ sender: UIBarButtonItem) {
        
        save()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    private func downloadProductImage(_ urlString: String) {
        
        let url = URL(string: urlString)!
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with: url, completionHandler: { [weak self] url, response, error in
            if error == nil, let url = url,
                
                let data = try? Data(contentsOf: url),
                
                let image = UIImage(data: data) {
                DispatchQueue.main.async() {
                    self?.productImageView.image = image
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
//                    self?.layer.masksToBounds = true
//                    self?.clipsToBounds = true
                } }
            
        })
        
        downloadTask.resume()
        
    }
    
    @IBAction func changeQuantity(_ sender: UIStepper) {
        
        let quantity = Int(sender.value)
        
        quantityLabel.text = "\(quantity)"
        let total = (product?.price)! * Double(quantity)
        
        totalLabel.text =  String(format: "%.2f", total)
        
    }
    
    func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
    
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Cart", in: managedContext)!
        
        var theCart: Cart!
        
        if let fetchedItem = itemFromCartWith(id: product!.key) {
            
            theCart = fetchedItem
            theCart.quantity += Int32(quantityLabel.text!)!
            
        } else {
            
            theCart = NSManagedObject(entity: entity, insertInto: managedContext) as! Cart
            
            theCart.productId = product?.key
            theCart.productImageUrl = product?.imageUrl
            theCart.productName = product?.name
            theCart.quantity = Int32(quantityLabel.text!)!
            theCart.unitPrice = (product?.price)!
            
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func itemFromCartWith(id: String) -> Cart? {
        
        var item: Cart? = nil
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return item
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cart")
        fetchRequest.predicate = NSPredicate(format: "productId == %@", id)
        
        do {
            item = try (managedContext.fetch(fetchRequest) as? [Cart])?.first
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return item
    }
    
}
