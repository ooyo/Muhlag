//
//  ViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/19/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import Material


extension UIStoryboard {
    class func viewController(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}

class ViewController: UIViewController {
  private var viewController2 = [ProductListViewController]()
    var window: UIWindow?
    
    
    var productViewController: ProductListViewController = {
        return UIStoryboard.viewController(identifier: "ProductListViewController") as! ProductListViewController
    }()

    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
       // view.backgroundColor = Color.red.base
        
      /*  for i in 1...5 {
            
            productViewController.category = "Hello"
            productViewController.categoryTitle = "hello world"
            productViewController.categoryID = 2
            viewController2.append(productViewController);
        } */
        
 
//        productViewController.category = "Hello"
//        productViewController.categoryTitle = "hello world"
//        productViewController.categoryID = 2
//        viewController2.append(productViewController);
//        print(productViewController.categoryTitle)
//        
//        productViewController.category = "Hello"
//        productViewController.categoryTitle = "hello world1"
//        productViewController.categoryID = 3
       // viewController2.append(productViewController);
       // print(productViewController.categoryTitle)
        

      //  productViewController.title = "Title"
    
        viewController2.append(ProductListViewController(category:"oidov", categoryTitle:"1", categoryID:1));
        viewController2.append(ProductListViewController(category:"oidov", categoryTitle:"2", categoryID:2));
        viewController2.append(ProductListViewController(category:"oidov", categoryTitle:"3", categoryID:3));
        viewController2.append(ProductListViewController(category:"oidov", categoryTitle:"4", categoryID:4));

        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = MainViewController(viewControllers: viewController2, selectedIndex: 0)
        window!.makeKeyAndVisible()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
    }
}


extension ViewController: TabBarDelegate {
    func tabBar(tabBar: TabBar, willSelect button: UIButton) {
        print("will select")
    }
    
    func tabBar(tabBar: TabBar, didSelect button: UIButton) {
        button.setTitleColor(tabSelectedColor, for: UIControlState.selected)
    }
}
