//
//  ContactUsTableViewController.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-25.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            
            if let phoneCallURL:URL = URL(string: "tel:6472336034")
            {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    
                    application.open(phoneCallURL)
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Feature not supported", message: "This feature is not supported by your device.", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    alertController.addAction(alertAction)
                    present(alertController, animated: true, completion: nil)
                    
                }
            }
            
        case 1:
            
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = ""
                controller.recipients = ["6472336034"]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Feature not supported", message: "This feature is not supported by your device.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alertController.addAction(alertAction)
                present(alertController, animated: true, completion: nil)
            }
            
        case 2:
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["c0695372@mylambton.com"])
//                mail.setMessageBody("<p>Sent from our app</p>", isHTML: true)
                
                present(mail, animated: true)
            } else {
                // show failure alert
            }
            
        default:
            break
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
}
