//
//  RealmCart.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/28/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCart: Object {
    
    dynamic var productID = 0
    dynamic var categoryID = 0
    dynamic var name = ""
    dynamic var size = ""
    dynamic var price = ""
    dynamic var discount = 0
    dynamic var quantity = 0
    dynamic var image = ""
    dynamic var status = 0
    
    override static func primaryKey() -> String? {
    
        return "productID"
    }
    
}


class RealmUserInfo: Object {
    
    dynamic var userID = 0
    dynamic var userName = ""
    dynamic var userPhone = ""
    dynamic var userAddress = ""
    dynamic var userToken = ""
    dynamic var userPhoneType = ""
    dynamic var userUniqueID = ""
    
    override static func primaryKey() -> String? {
        return "userID"
    }
}


class RealmOrder: Object {
    dynamic var primaryID: Int = 0
    dynamic var totalPrice: Float = 0.0
    dynamic var createdAt: String = ""
    dynamic var orderID: String = ""
    dynamic var deliveryName: String = ""
    dynamic var deliveryTime: String = ""
    dynamic var deliveryPhone: String = "" 
    dynamic var status: Int = 0
    
    
    override static func primaryKey() -> String? {
        return "primaryID"
    }
    
}
