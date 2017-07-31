//
//  CartCell.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-20.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {
    
    var downloadTask: URLSessionDownloadTask?

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var unitPriceLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        self.productImageView.image = #imageLiteral(resourceName: "placeholder-image")
    }
    
}
