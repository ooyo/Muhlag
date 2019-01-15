//
//  DeliveryViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/19/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import BubbleTransition
import RealmSwift
import Alamofire
import SwiftyJSON
class DeliveryViewController: UIViewController {

    @IBOutlet weak var stepImage: UIImageView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var phoneText: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var orderTitleTxt: UILabel!
    var orderID: String? = "empty"
    let transition = BubbleTransition()
    var resultDictionary:NSMutableDictionary = NSMutableDictionary()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadAndUpdate()
    }
    func downloadAndUpdate() {
        
        let realm = try! Realm()
        let myOrder = realm.objects(RealmOrder.self).first
        let userInfo = realm.objects(RealmUserInfo.self).first
        let myCart = realm.objects(RealmCart.self)
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        var parameters: Parameters = ["":""];
        if  orderID != "empty" {
            parameters = ["user_id":userInfo?.userID as Any ,"order_id":orderID ?? "0"]
        }else{
            parameters = ["user_id":userInfo?.userID as Any ,"order_id":myOrder?.orderID as Any]
        }
        
        Alamofire.request(orderDetailURL, method: HTTPMethod.post, parameters:parameters,encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON VALUE :", value);
               self.resultDictionary.setDictionary(json["result"].dictionaryObject!)
                if(json["status"].intValue == 0){
                    //step1
                    self.stepImage.image = UIImage(named: "step1")
                    self.orderTitleTxt.text = "Захиалга бүртгэгдсэн"
                    self.detailTextView.text = "Таны захиалга амжилттай бүртгэгдлээ. Бид таньтай захиалга баталгаажуулах талаар дуудлага удахгүй хийх тул та түр хүлээнэ үү. \n\n Баярлалаа"
                    self.phoneText.text = "Захиалгын дугаар: " + (myOrder?.orderID.description)!
                }else if(json["status"].intValue == 4){
                    try! realm.write {
                        myOrder?.deliveryName = self.resultDictionary.value(forKey: "deliveryName") as! String
                        myOrder?.deliveryTime = self.resultDictionary.value(forKey: "deliver_time") as! String
                        myOrder?.deliveryPhone = self.resultDictionary.value(forKey: "deliveryPhone") as! String
                    }
                    //step2
                    print("Delivery name:", self.resultDictionary.value(forKey: "deliveryName") as! String)
                    self.stepImage.image = UIImage(named: "step2")
                    self.orderTitleTxt.text = "Захиалга баталгаажсан"
                    self.detailTextView.text = "Таны захиалга амжилттай баталгаажсан тул хүргэлтэнд гарсан байна. Таны захиалга \(self.resultDictionary.value(forKey: "deliver_time") as! String) дотор хүргэгдэнэ. Та доорхи утасаар хүргэлтийн талаар дэлгэрэнгүй лавлана уу."
                   // self.phoneText.text = "Утасны дугаар: \((myOrder?.deliveryPhone)!)"
                }else if(json["status"].intValue == 5){
                    //step3
                    try! realm.write {
                        realm.delete(myOrder!)
                        realm.delete(myCart)
                    }
                    self.stepImage.image = UIImage(named: "step3")
                    self.orderTitleTxt.text = "Захиалга хүргэгдсэн"
                    self.detailTextView.text = "Таны захиалга амжилттай хүргэгдлээ. Биднийг сонгон үйлчлүүлсэн таньд баярлалаа. \n Манай аппликейшныг дараа дахин ашиглаарай.  "
                    self.phoneText.text = "Баярлалаа"
                }else{
                    //delete order realm and back to home page, (order is cancelled)
                    //required new page that shows order is cancelled
                    try! realm.write {
                        realm.delete(myOrder!)
                        realm.delete(myCart)
                    }
                    
                    self.stepImage.image = UIImage(named: "step0")
                    self.orderTitleTxt.text = "Захиалга цуцлагдсан"
                    self.detailTextView.text = "Таны захиалга амжилттай цуцлагдсан байна. Биднийг сонгон үйлчлүүлсэн таньд баярлалаа. \n Манай аппликейшныг дараа дахин ашиглаарай.  "
                    self.phoneText.text = "Баярлалаа"
                }
                
            case .failure(let error):
                if let err = error as? URLError, err.code  == URLError.Code.notConnectedToInternet
                {
                    
                }
                else
                {
                    
                }
                
                
            }
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToHomeAction(_ sender: Any) {
        performSegue(withIdentifier: "backToHome", sender: nil)
    }

    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = backBtn.center
        transition.bubbleColor = UIColor.white
        return transition
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = backBtn.center
        transition.bubbleColor = UIColor.white//checkOutBtn.backgroundColor!
        return transition
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
