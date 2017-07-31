//
//  ViewController.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-14.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if FBSDKAccessToken.current() == nil {
            let loginButton = FBSDKLoginButton()
            loginButton.delegate = self
            loginButton.readPermissions = ["public_profile", "email", "user_friends"];
            loginButton.center = self.view.center
            self.view.addSubview(loginButton)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if FBSDKAccessToken.current() != nil {
            self.checkUserRegister(FBSDKAccessToken.current().userID!)
        
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func proceedToStore() {
        
        if let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
            
            mainTabBarController.modalTransitionStyle = .crossDissolve
            present(mainTabBarController, animated: true, completion: nil)
            
        }
        
    }
    
    func proceedToRegister() {
        
        if let registerViewController = storyboard?.instantiateViewController(withIdentifier: "RegisterController") as? RegisterViewController {
            
            registerViewController.modalTransitionStyle = .crossDissolve
            registerViewController.newUser = true
            present(registerViewController, animated: true, completion: nil)
            
        }
        
    }

}

extension ViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        if result.isCancelled {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            print("User is signed in")
            self.checkUserRegister(FBSDKAccessToken.current().userID!)
            // ...
        }
    }
    func checkUserRegister(_ uid:String){
        var exist = false
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("user").child(uid).observe(.value, with: { (snapshot: DataSnapshot) in
//            for snap in snapshot.children {
            for _ in snapshot.children {
//                print((snap as! DataSnapshot).value)
                exist = true
                break
            }
            if(exist){
                self.proceedToStore()
            }else{
                self.proceedToRegister()
            }
        })
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}



















