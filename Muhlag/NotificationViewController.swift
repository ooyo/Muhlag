//
//  NotificationViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/31/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire
class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var result : NSMutableArray = NSMutableArray()
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
        
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTableInfo()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NotificationTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationTableViewCell
        let singleNotif: NSDictionary = self.result[indexPath.row] as! NSDictionary
        if singleNotif.object(forKey: "type") as! String == "message" {
            cell.notificationText.text = singleNotif.object(forKey: "message") as! String!
             cell.notificationText.textColor = UIColor(colorLiteralRed: 142.0/255.0, green: 142.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        }else if singleNotif.object(forKey: "type") as! String == "product" {
             cell.notificationText.text = "\(singleNotif.object(forKey: "productName") as! String) \(singleNotif.object(forKey: "message") as! String) "
             cell.notificationText.textColor = UIColor(colorLiteralRed: 142.0/255.0, green: 142.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        }else if singleNotif.object(forKey: "type") as! String == "order" {
            cell.notificationText.textColor = UIColor(colorLiteralRed: 76.0/255.0, green: 76.0/255.0, blue: 76.0/255.0, alpha: 1.0)
            if singleNotif.object(forKey: "status") as! Int == 0 {
                //placed
                 cell.notificationText.text = "\(singleNotif.object(forKey: "order_id") as! String) дугаартай захиалга амжилттай бүртгэгдлээ. "
                
            }else if singleNotif.object(forKey: "status") as! Int == 4 {
                //accepted
                cell.notificationText.text = "\(singleNotif.object(forKey: "order_id") as! String) дугаартай захиалга амжилттай хүргэлтэнд гарлаа. "
            }else if singleNotif.object(forKey: "status") as! Int == 5 {
                //delivered
                cell.notificationText.text = "\(singleNotif.object(forKey: "order_id") as! String) дугаартай захиалга амжилттай хүргэгдлээ. "
                
            }else{
                //cancelled
                cell.notificationText.text = "\(singleNotif.object(forKey: "order_id") as! String) дугаартай захиалга амжилттай цуцлагдсан байна. "
            }
            
            
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let singleNotif: NSDictionary = self.result[indexPath.row] as! NSDictionary
        
        if singleNotif.object(forKey: "type") as! String == "order" {
        
            let viewController = storyboard.instantiateViewController(withIdentifier :"DetailViewController") as! DeliveryViewController
            viewController.orderID = singleNotif.object(forKey: "order_id") as! String!
            self.present(viewController, animated: true)

        }else if singleNotif.object(forKey: "type") as! String == "product" {
         self.performSegue(withIdentifier: "segueToHome", sender: nil)
        }else{
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToHome" {
            let newViewController = segue.destination as! TabManViewController
       
            
            let indexPath = self.tableView.indexPathForSelectedRow
            let singleNotif: NSDictionary = self.result[(indexPath?.row)!] as! NSDictionary
            
               newViewController.selectedTab = singleNotif.value(forKey: "category") as! Int?
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateTableInfo(){
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        var parameters: Parameters = ["":""];
        let userInfo = self.realm.objects(RealmUserInfo.self).first
        parameters = ["user_id": userInfo?.userID.description ?? ""]
            Alamofire.request(notificationListURL, method: HTTPMethod.post, parameters:parameters,encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.result.setArray(json["result"].arrayObject!)
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print(error)
                }
                
            }
            
      
    }
}
