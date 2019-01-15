//
//  CartTableViewCell.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/28/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productSize: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productMinus: UIButton!
    @IBOutlet weak var productQuantity: UILabel!
    @IBOutlet weak var productPlus: UIButton!
    var minusAction : (() -> Void)? = nil
    var plusAction : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        productQuantity.layer.cornerRadius = 3.0
        productQuantity.layer.borderWidth = 1.0
        productQuantity.layer.borderColor =  UIColor(red: 201.0/255.0, green: 83/255.0, blue: 47.0/255.0, alpha:1.0).cgColor
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btnMinusAction(sender: UIButton)
    {
        if let btnAction = self.minusAction
        {
            btnAction()
        }
    }
    
    @IBAction func btnPlusAction(sender: UIButton)
    {
        if let btnAction = self.plusAction
        {
            btnAction()
        }
    }

}
