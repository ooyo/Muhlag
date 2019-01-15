//
//  AgeRestrictViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/19/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Material
import CocoaBar
import RealmSwift
class AgeRestrictViewController: UIViewController, CocoaBarDelegate {
    let userToken: String = ""
    var userUniqueID: String = ""
    let userAppType: String = "appNameIOS"
    var userID: String = ""
    var result : NSMutableArray = NSMutableArray()
    var styles: BarStyle = BarStyle(title: "",
                                   description: "1Action layout with dark blur background and rounded rectangular display",
                                   backgroundStyle: .blurLight,
                                   displayStyle: .roundRectangle,
                                   barStyle: .action,
                                   duration: .short)
    

    let realm = try! Realm()
  
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var exitBtm: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userUniqueID = UserDefaults.standard.value(forKey: "ApplicationIdentifier")! as! String
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let userInfoDB = realm.objects(RealmUserInfo.self)
        if userInfoDB.count != 0 {
            self.performSegue(withIdentifier: "ageAcceptedSegue", sender: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       CocoaBar.keyCocoaBar?.delegate = self
       
        loginBtn.layer.cornerRadius = loginBtn.frame.size.height/2
        exitBtm.layer.cornerRadius = exitBtm.frame.size.height/2
    }
    
    
    @IBAction func ageAcceptAction(_ sender: Any) {
            downloadAndUpdate()
    }

    @IBAction func ageDeclineAction(_ sender: Any) {
            exit(0)

    }
    
    func downloadAndUpdate() {
        let headers: HTTPHeaders = [
            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        var parameters: Parameters = ["":""];
        parameters = ["unique_id":userUniqueID,"phone_type":userAppType, "phone_token": defaults.value(forKey: "api_token")!]
        print("parameters", parameters)
        Alamofire.request(clientRegisterURL, method: HTTPMethod.post, parameters:parameters,encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("JSON VALUE :", value);
                    
                    let userInfo = RealmUserInfo()
                    userInfo.userID = json["result"].intValue
                    userInfo.userPhoneType = self.userAppType
                    userInfo.userToken = defaults.value(forKey: "api_token") as! String
                    userInfo.userUniqueID = self.userUniqueID

                    
                    try! self.realm.write {
                        self.realm.add(userInfo, update:true)
                    }
                    
                    
                    defaults.setValue(json["result"].stringValue, forKey: "userid")
                   self.performSegue(withIdentifier: "ageAcceptedSegue", sender: nil)
                    
                case .failure(let error):
                    if let err = error as? URLError, err.code  == URLError.Code.notConnectedToInternet
                    {
                         self.styles.title = "Интернэт холболт байхгүй байна"
                        if let keyCocoaBar = CocoaBar.keyCocoaBar {
                            if keyCocoaBar.isShowing {
                                keyCocoaBar.delegate = nil // temporarily ignore cocoa bar delegate
                                keyCocoaBar.hideAnimated(true, completion: { (animated, completed, visible) in
                                    self.showBarWithStyle(self.styles)
                                    keyCocoaBar.delegate = self
                                })
                            } else {
                                self.showBarWithStyle(self.styles)
                            }
                        }

                    }
                    else
                    {
                     
                        self.styles.title = "Сервертэй холбоотой алдаа гарлаа"
                        if let keyCocoaBar = CocoaBar.keyCocoaBar {
                            if keyCocoaBar.isShowing {
                                keyCocoaBar.delegate = nil // temporarily ignore cocoa bar delegate
                                keyCocoaBar.hideAnimated(true, completion: { (animated, completed, visible) in
                                    self.showBarWithStyle(self.styles)
                                    keyCocoaBar.delegate = self
                                })
                            } else {
                                self.showBarWithStyle(self.styles)
                            }
                        }
                    }


                }
                
            }
    }
    
    
    // MARK: CocoaBarDelegate
    
    func cocoaBar(_ cocoaBar: CocoaBar, willShowAnimated animated: Bool) {
        
    }
    
    func cocoaBar(_ cocoaBar: CocoaBar, didShowAnimated animated: Bool) {
        // did show bar
    }
    
    func cocoaBar(_ cocoaBar: CocoaBar, willHideAnimated animated: Bool) {
        
    }
    
    func cocoaBar(_ cocoaBar: CocoaBar, didHideAnimated animated: Bool) {
        
    }
    
    func cocoaBar(_ cocoaBar: CocoaBar, actionButtonPressed actionButton: UIButton?) {
        // Do an action
        cocoaBar.hideAnimated(true, completion: nil)
        
    }

    
    
    
    //MARK SHOW 
    
    fileprivate func showBarWithStyle(_ style: BarStyle) {
        if style.layout != nil {
            
            CocoaBar.showAnimated(true, duration: style.duration, layout: style.layout, populate: { (layout) in
                self.populateLayout(style, layout: layout)
            }, completion: nil)
        }
        
        CocoaBar.showAnimated(true, duration: style.duration, style: style.barStyle, populate: { (layout) in
            self.populateLayout(style, layout: layout)
        }, completion: nil)
    }
    
    
    fileprivate func populateLayout(_ style: BarStyle, layout: CocoaBarLayout) {
        layout.backgroundStyle = style.backgroundStyle
        layout.displayStyle = style.displayStyle
        
        if let actionLayout = layout as? CocoaBarActionLayout {
            actionLayout.titleLabel?.text = style.title
            actionLayout.actionButton?.setTitle("OK", for: UIControlState())
        }
    }
    
    fileprivate func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

}


 
