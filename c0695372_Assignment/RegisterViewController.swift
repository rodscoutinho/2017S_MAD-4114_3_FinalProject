//
//  RegisterViewController.swift
//  c0695372_Assignment
//
//  Created by Danilo Silveira on 2017-07-20.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseDatabase

class RegisterViewController: UIViewController {

    @IBOutlet weak var uiImg: UIImageView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtName: UITextField!
    private var ref: DatabaseReference!
    var perfilUrl:String = ""
    var newUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
        
        if(newUser){
            
            FBSDKAccessToken.current()
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name, email, picture"])
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if (error != nil)
                {
                    // Process error
                    print("Error: \(error!.localizedDescription)")
                }
                else
                {
//                    print("fetched user: \(result)")
                    let fbDetails = result as! NSDictionary
                    let email = fbDetails.value(forKey: "email") as! String
                    self.txtEmail.text = email
                    self.txtName.text = fbDetails.value(forKey: "name") as? String
                    let picture = fbDetails.value(forKey: "picture") as! NSDictionary
                    let data = picture.value(forKey: "data") as! NSDictionary
                    print("picture: \(data)")
                    
                    self.perfilUrl = data.value(forKey: "url")! as! String
                    let imgURL = URL(string: self.perfilUrl)
                    self.loadImg(imgURL!)
                    
                    //self.txtPhone.text = fbDetails.value(forKey: "phone") as! String
                    
                }
            })

        }else{
            var ref: DatabaseReference!
            
            ref = Database.database().reference()
            let uid = FBSDKAccessToken.current().userID!
            ref.child("user").child(uid).observe(.value, with: { (snapshot: DataSnapshot) in
                let userEdit = snapshot.value as! [String:String]
                self.txtPhone.text = userEdit["phone"]
                self.txtName.text = userEdit["name"]
                self.txtEmail.text = userEdit["email"]
                self.perfilUrl = userEdit["imageUrl"]!
                let imgURL = URL(string: self.perfilUrl)
                self.loadImg(imgURL!)
                
                /*for snap in snapshot.children {
                    print("result: \((snap as! DataSnapshot).value!)")
                    
                    
                }*/
               
            })
        
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func loadImg(_ imgURL:URL){
        let task = URLSession.shared.dataTask(with: imgURL) { (data, response, error) in
            if error == nil {
                let downloadImage = UIImage(data: data!)
                
                //performUIUpdatesOnMain {
                //    self.imageview.image = downloadImage
                //}
                
                DispatchQueue.main.async {
                    self.uiImg.image = downloadImage
                }
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAlertControllerWith(title: String, and text: String) {
        
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnSave(_ sender: Any) {
        guard let email = txtEmail.text, email.isAValidEmail() else {
            presentAlertControllerWith(title: "Invalid email address", and: "Please provide a valid email address")
            return
        }
        
        guard let name = txtName.text, !name.isEmpty else {
            presentAlertControllerWith(title: "Invalid name", and: "Please provide your name")
            return
        }
        
        /*
        if !txtEmail.text!.isAValidEmail() {
            presentAlertControllerWith(title: "Invalid email address", and: "Please provide a valid email address")
            return
        }
 */
        
        self.ref = Database.database().reference()
        let user: [String: Any] = ["email" : email,
                                   "name" : name,
                                   "phone" : txtPhone.text!,
                                   "imageUrl": perfilUrl]
        self.ref.child("user").child(FBSDKAccessToken.current().userID!).setValue(user)
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
