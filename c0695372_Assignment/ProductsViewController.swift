//
//  ProductsViewController.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-14.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit

class ProductsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var searchController: UISearchController!
    fileprivate var products = [Product]()
    fileprivate var searchResults = [Product]()
    fileprivate var hasSearched = false
    
    private var ref: DatabaseReference!
    private var uID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        uID = Auth.auth().currentUser?.uid
        
        self.ref = Database.database().reference()
        
        let cellNib = UINib(nibName: "ProductTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ProductCell")
        
        tableView.estimatedRowHeight = 142.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchProducts()
    }
    
    func fetchProducts() {
        
        self.products = []
        
        ref.child("products").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            let productsDict = value as! [String: Any]
            
            for (key, value) in productsDict {
                let productDetails = value as! [String: Any]
                
                let product = Product(name: productDetails["productName"] as! String,
                                      categoryName: productDetails["categoryName"] as! String,
                                      price: productDetails["price"] as! Double,
                                      imageUrl: productDetails["imageUrl"] as! String,
                                      key: key)
                self.products.append(product)
            }
            
            self.tableView.reloadData()
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetails" {
            
            if let indexPath = sender as? IndexPath {

                
                let productDetailTableViewController = segue.destination as! ProductDetailTableViewController
                
//                let product = products[indexPath.row]
//                productDetailTableViewController.product = product
                
                productDetailTableViewController.product = (searchController.isActive) ?
                    self.searchResults[indexPath.row] : self.products[indexPath.row]
                
                searchController.isActive = false
            }
            
        }
        
    }
    
    @IBAction func settingBtn(_ sender: Any) {
        let alertController =  UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .default) { (action) in
            //logout aqui
            
            try! Auth.auth().signOut()
            
            FBSDKLoginManager().logOut()
            self.dismiss(animated: true, completion: nil)
            
        }
        let profileAction = UIAlertAction(title: "Edit Profile", style: .default) { (action) in
            if let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterController") {
                
                mainTabBarController.modalTransitionStyle = .crossDissolve
                self.present(mainTabBarController, animated: true, completion: nil)
                
            }
        }
        
        let addProductAction = UIAlertAction(title: "Add product", style: .default) { (action) in
            self.showInputDialog()
        }
        
        alertController.addAction(profileAction)
        alertController.addAction(addProductAction)
        alertController.addAction(logoutAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func dismissCart(segue: UIStoryboardSegue) {
        
    }
    
    func filterProducts(for searchText: String) {
        searchResults = products.filter({ (product) -> Bool in
            let nameMatches = product.name.localizedCaseInsensitiveContains(searchText)
            let categoryMatches = product.categoryName.localizedCaseInsensitiveContains(searchText)
            return nameMatches || categoryMatches
        })
    }
    
    func showInputDialog() {
        let alertController = UIAlertController(title: "Restricted access", message: "Enter your user name and password", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            let userName = alertController.textFields?[0].text
            let password = alertController.textFields?[1].text
            
            if userName == "admin" &&
                password == "admin" {
                
                if let insertItemTableNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "InsertItemTableNavigationController") as? UINavigationController {
                    
                    insertItemTableNavigationController.modalTransitionStyle = .crossDissolve
                    self.present(insertItemTableNavigationController, animated: true, completion: nil)
                    
                }
                
            } else {
                
                let alertController = UIAlertController(title: "Access denied", message: "Wrong credentials", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
//            self.labelMessage.text = "Name: " + name! + "Email: " + email!
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "User name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension ProductsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: indexPath)
    }
    
}

extension ProductsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return self.searchResults.count
        } else {
            return self.products.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableViewCell
        
//        let product = self.products[indexPath.row]
        let product = (searchController.isActive) ? self.searchResults[indexPath.row]
            : self.products[indexPath.row]
        
        cell.productNameLabel.text = product.name
        cell.categoryNameLabel.text = product.categoryName
        cell.priceLabel.text = String(format: "%.2f", product.price)
        
        
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.center = cell.center
        activityIndicatorView.startAnimating()
        cell.productImageView.addSubview(activityIndicatorView)
        
        let url = URL(string: product.imageUrl)!
        cell.downloadTask = cell.productImageView.loadImage(url: url)
        
        return cell
    }
    
}

extension ProductsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterProducts(for: searchText)
            tableView.reloadData()
        }
    }
    
}

























