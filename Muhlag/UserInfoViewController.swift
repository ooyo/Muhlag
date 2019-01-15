//
//  UserInfoViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/19/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftValidator
import Alamofire
import MMLoadingButton
import SwiftyJSON

class UserInfoViewController: UIViewController, UITextViewDelegate,ValidationDelegate, UITextFieldDelegate {

    var parameters: Parameters = ["":""];
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var userPhoneTxt: UITextField!
    @IBOutlet weak var userAddressTxt: UITextView!
    @IBOutlet weak var userAdditionalTxt: UITextView!
    @IBOutlet weak var btnOrder: MMLoadingButton!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    let realm = try! Realm()
    var dataSource: Results<RealmCart>!
    let validator = Validator()

    var result : NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userAddressTxt.delegate = self
       
        validator.registerField(self.userNameTxt, rules: [RequiredRule()])
        validator.registerField(self.userPhoneTxt, rules: [RequiredRule()])
   }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userNameTxt.borderWidth = 1
        self.userNameTxt.borderColor = UIColor(colorLiteralRed: 201.0/255.0, green: 83.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        self.userNameTxt.cornerRadius = 3.0
        
        self.userPhoneTxt.borderWidth = 1
        self.userPhoneTxt.borderColor = UIColor(colorLiteralRed: 201.0/255.0, green: 83.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        self.userPhoneTxt.cornerRadius = 3.0
        
        
        self.userAddressTxt.borderWidth = 1
        self.userAddressTxt.borderColor = UIColor(colorLiteralRed: 201.0/255.0, green: 83.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        self.userAddressTxt.cornerRadius = 3.0
        
        self.userAdditionalTxt.borderWidth = 1
        self.userAdditionalTxt.borderColor = UIColor(colorLiteralRed: 201.0/255.0, green: 83.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        self.userAdditionalTxt.cornerRadius = 3.0
        
        
        
         self.btnOrder.cornerRadius = self.btnOrder.layer.frame.size.height/2
        
        
        let userInfo = self.realm.objects(RealmUserInfo.self).first
        print("Userinfo: \(userInfo?.userName)")
        self.userNameTxt.text = userInfo?.userName
        self.userPhoneTxt.text = userInfo?.userPhone
        self.userAddressTxt.text = userInfo?.userAddress
        
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userAddressTxt.resignFirstResponder()
        
        return true
    }
    
    
    @IBAction func btnOrderAction(_ sender: AnyObject) {
        validator.validate(self)
        btnOrder.startLoading()
        
    }
    
    
    func validationSuccessful() {
        let userInfo = self.realm.objects(RealmUserInfo.self).first
        let cartProducts = self.realm.objects(RealmCart.self)
        
        try! realm.write {
            userInfo?.userName = self.userNameTxt.text!
            userInfo?.userPhone = self.userPhoneTxt.text!
            userInfo?.userAddress = self.userAddressTxt.text
            
        }
        
        var counter:Int = 0
        var totalPrice:Float = 0.0
        for i in cartProducts {
            counter += 1
            parameters.updateValue(i.productID, forKey: "field_id_\(counter)")
            parameters.updateValue(i.price, forKey: "field_price_\(counter)")
            parameters.updateValue(i.quantity, forKey: "field_quantity_\(counter)")
            totalPrice = totalPrice + (Float(i.price)! * Float(i.quantity))
        }
        
        parameters.updateValue(userInfo?.userID ?? "", forKey: "user_id")
        parameters.updateValue(userInfo?.userName ?? "", forKey: "user_name")
        parameters.updateValue(cartProducts.count, forKey: "number_of_product")
        parameters.updateValue(userInfo?.userPhone ?? "", forKey: "user_phone")
        parameters.updateValue(userInfo?.userAddress ?? "", forKey: "user_address")
        parameters.updateValue(totalPrice, forKey: "total_price")
        parameters.updateValue(userAdditionalTxt.text, forKey: "additional_request")
        
        print("parameters:", parameters.description)
        
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        
      
       // parameters = ["app_name":"appNameIOS", "api_token": defaults.value(forKey: "api_token")!]
        Alamofire.request(newOrderURL, method: HTTPMethod.post, parameters:parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON \(json)")
                self.btnOrder.stopLoading(true, completed: {
                    let cartProducts = self.realm.objects(RealmCart.self)
                    try! self.realm.write {
                        for i in cartProducts {
                           i.status = 1
                        }
                    }
                    
                })
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                    if json["resultCode"] == "1" {
                        self.result.setDictionary(json["result"].dictionaryObject!)
                        let newOrder = RealmOrder()
                        
                        print("Result: orderid \(self.result["order_id"])")
                        print("Result: orderid2 ", self.result.value(forKey: "order_id") ?? "no order id")
                        
                        newOrder.primaryID = self.result.value(forKey: "id") as! Int
                        newOrder.totalPrice = self.result.value(forKey: "total_price") as! Float
                        newOrder.createdAt = self.result.value(forKey: "created_at") as! String
                        newOrder.orderID = self.result.value(forKey: "order_id") as! String
                        newOrder.status = self.result.value(forKey: "status") as! Int
                        
                        try! self.realm.write {
                            self.realm.add(newOrder, update:true)
                        }

                        self.performSegue(withIdentifier: "orderIsPlaced", sender: nil)
                    }

                
                }
                //self.result.setArray(json["result"].arrayObject!)
                //self.collectionView.reloadData();
                
            case .failure(let error):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                    self.btnOrder.stopWithError("Захиалга амжилтгүй", hideInternal: 2, completed: {
                        print(error.localizedDescription)
                    })
                
                }
               
            }
            
        }
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
