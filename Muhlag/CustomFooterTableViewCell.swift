//
//  CustomFooterTableViewCell.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/28/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit

class CustomFooterTableViewCell: UITableViewCell {

    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
     var acceptAction : (() -> Void)? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        btnAccept.layer.cornerRadius = btnAccept.layer.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnAcceptAction(sender: UIButton)
    {
        if let btnAction = self.acceptAction
        {
            btnAction()
        }
    }
    
}
