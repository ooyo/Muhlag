//
//  CheckOutViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/28/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    var dataSource1: Results<RealmCart>!
    
    @IBOutlet weak var customNavi: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.setupUI()
        reloadTheTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    func reloadTheTable(){
        
            dataSource1 = realm.objects(RealmCart.self)
            tableView.reloadData()
        
        if dataSource1.count == 0 {
            dismiss(animated: true, completion: nil)
        }
            //tableView.tableFooterView?.reloadInputViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.0, animations: {
            self.tableView.isHidden = false
            self.customNavi.isHidden = false
        })

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.1, animations: {
            self.tableView.isHidden = true
            self.customNavi.isHidden = true
        })
    }
    @IBAction func backAction(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CartTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cartCell") as! CartTableViewCell
        
        let currentCartInfo = dataSource1[indexPath.row]
        
        cell.productName.text = currentCartInfo.name
       
        if currentCartInfo.discount > 0 {
            let productPrice: Int32 = Int32(Float(currentCartInfo.price)! * 1000)
            let discountMNT =  (productPrice / 100) * Int32(currentCartInfo.discount)
            let priceCalculate = Float(productPrice - discountMNT) / 1000.0;
            
            cell.productPrice.text = "MNT " + String(format: "%.2f", priceCalculate)
        }else{
            cell.productPrice.text = "MNT " + currentCartInfo.price
        }
        
        cell.productSize.text = "(" + currentCartInfo.size + ")"
        
        cell.productImage.kf.indicatorType = .activity
        let imageURL = URL(string: productImagePublicURL + currentCartInfo.image)
        let resource = ImageResource(downloadURL:imageURL!, cacheKey: productImagePublicURL + currentCartInfo.image)
        cell.productImage.kf.setImage(with: resource, options: [.transition(.fade(0.2))])
        
        cell.productQuantity.text = currentCartInfo.quantity.description
        
        cell.minusAction={
            if currentCartInfo.quantity == 1{
                try! self.realm.write {
                    self.realm.delete(currentCartInfo)
                }
                self.reloadTheTable()
            }else{
                try! self.realm.write {
                    currentCartInfo.quantity = currentCartInfo.quantity - 1;
                }
                self.reloadTheTable()
                

            }
        }
        
        cell.plusAction={
            try! self.realm.write {
                currentCartInfo.quantity = currentCartInfo.quantity + 1;
            }
            self.reloadTheTable()
        }        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let  footerCell = tableView.dequeueReusableCell(withIdentifier: "customFooterCell") as! CustomFooterTableViewCell
        
        let myCartList = realm.objects(RealmCart.self)
        var totalPrice: Float = 0.0
        for product in myCartList {
           
            if product.discount > 0 {
                let productPrice: Int32 = Int32(Float(product.price)! * 1000)
                let discountMNT =  (productPrice / 100) * Int32(product.discount)
                let priceCalculate = Float(productPrice - discountMNT) / 1000.0;
                totalPrice = totalPrice + (Float(String(format: "%.2f", priceCalculate))! * Float(product.quantity))
            }else{
                
                totalPrice = totalPrice + (Float(product.price)! * Float(product.quantity))
            }

        }
        footerCell.totalPrice.text = String(describing: totalPrice) + " ₮"
        
        
        footerCell.acceptAction={
            self.performSegue(withIdentifier: "provideInformationSegue", sender: nil)
        }
        return footerCell
    }
    
    
    func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 190.0;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110.0;//Choose your custom row height
    }

    

}
