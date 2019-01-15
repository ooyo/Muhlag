//
//  ProductTableViewCell.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/24/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productSize: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var productImageWebView: UIImageView!
     var addToCartAction : (() -> Void)? = nil
    
    @IBOutlet weak var productOldPrice: UILabel!
    @IBOutlet weak var productNewPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        productButton.layer.cornerRadius = productButton.layer.frame.size.height/2
        productButton.layer.borderWidth = 1.0
        productButton.layer.borderColor =  UIColor(red: 201.0/255.0, green: 83/255.0, blue: 47.0/255.0, alpha:1.0).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnAction(sender: UIButton)
    {
        if let btnAction = self.addToCartAction
        {
            btnAction()
        }
    }



}
