//
//  InsertItemTableViewController.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-25.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage

class InsertItemTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var ref: DatabaseReference!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var NameTxt: UITextField!
    @IBOutlet weak var PriceTxt: UITextField!
    @IBOutlet weak var CatPicker: UIPickerView!
    var cat:[String] = ["Electronics","E-Book Readers","Video-Games","Home & Kitchen","Phone","Computer"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhoto(_:))))
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    }
    
    func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func selectPhoto(_ gesture: UITapGestureRecognizer) {
        
        let photoSelectionActionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            photoSelectionActionController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
                
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            photoSelectionActionController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
                
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
                
            }))
        }
        
        photoSelectionActionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(photoSelectionActionController, animated: true, completion: nil)
        
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveProduct(_ sender: UIBarButtonItem) {
        
        self.ref = Database.database().reference()
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        if let img = myImageView.image{
            // Data in memory
            let data = UIImagePNGRepresentation(img) as Data?
            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("\(self.NameTxt.text!).jpg")
            
            // Upload the file to the path "images/rivers.jpg"
            /*let uploadTask = */riversRef.putData(data!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
                
                let product: [String: Any] = [
                    "productName" : self.NameTxt.text!,
                    "categoryName" : self.cat[self.CatPicker.selectedRow(inComponent: 0)],
                    "price" : Double(self.PriceTxt.text!) ?? 00.00,
                    "imageUrl": downloadURL()!.absoluteString]
                self.ref.child("products").childByAutoId().setValue(product)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cat.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cat[row]
    }

}

extension InsertItemTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.myImageView.image = selectedImage
            self.myImageView.contentMode = .scaleAspectFill
            self.myImageView.clipsToBounds = true
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


































