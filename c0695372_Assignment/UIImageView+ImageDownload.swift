//
//  UIImageView+ImageDownload.swift
//  Day2
//
//  Created by Rodrigo Coutinho on 2017-07-07.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImage(url: URL) -> URLSessionDownloadTask {
        
        let session = URLSession.shared

        let downloadTask = session.downloadTask(with: url, completionHandler: { [weak self] url, response, error in
                if error == nil, let url = url,
                    
                    let data = try? Data(contentsOf: url),
                    
                    let image = UIImage(data: data) {
                    /*DispatchQueue.main.async() {
                        if let strongSelf = self {
                            strongSelf.image = image
                        }
                    } }*/
                    DispatchQueue.main.async() {
                        if let activityIndicatorView = self?.subviews.last as? UIActivityIndicatorView {
                            activityIndicatorView.stopAnimating()
                            activityIndicatorView.removeFromSuperview()
                        }
                        
                        self?.image = image
                        self?.layer.masksToBounds = true
                        self?.clipsToBounds = true
                    } }
            
        })
        
        downloadTask.resume()
        return downloadTask
        
    }
    
}
