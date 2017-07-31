//
//  OrderTableViewCell.swift
//  c0695372_Assignment
//
//  Created by Rodrigo Coutinho on 2017-07-24.
//  Copyright © 2017 Rodrigo Coutinho. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    @IBOutlet var orderDateLabel: UILabel!
    @IBOutlet var numberOfItemsLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
