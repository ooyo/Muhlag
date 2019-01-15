//
//  TabManViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/25/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import AMPopTip
class TabManViewController: TabmanViewController, PageboyViewControllerDataSource  {
 
    // MARK: Constants
    
    // MARK: Outlets
    var products:[CategorySpecies]?
    var productWrapper: CategoryListWrapper?
    var popViewController: NotificationViewController!
    var selectedTab: Int? = 1
    // MARK: Properties
    var popViewShow: Bool! = false
    var previousBarButton: UIBarButtonItem?
    var nextBarButton: UIBarButtonItem?
    var tabAppearance: TabmanBar.Appearance?
    // MARK: Lifecycle
    
    let popTip = AMPopTip()

    @IBOutlet weak var notificationBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.addBarButtons()
        //self.view.sendSubview(toBack: self.gradientView)
        self.loadFirstSpecies()
        self.popTip.offset = -30
        self.popTip.arrowSize = CGSize(width: 30, height:15)
        self.popTip.popoverColor = UIColor.white
        self.popTip.entranceAnimation = AMPopTipEntranceAnimation.fadeIn
        self.popTip.exitAnimation = AMPopTipExitAnimation.fadeOut
        
        self.popTip.layer.shadowColor = UIColor.black.cgColor
        self.popTip.layer.shadowOpacity = 1
        self.popTip.layer.shadowOffset = CGSize.zero
        self.popTip.layer.shadowRadius = 4

      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        
     //   if let navigationController = segue.destination as? SettingsNavigationController,
     //       let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {
     //       settingsViewController.tabViewController = self
     //   }
        
        // use current gradient as tint
        
    }
    
    // MARK: Actions
    
    @objc func firstPage(_ sender: UIBarButtonItem) {
        self.scrollToPage(.first, animated: true)
    }
    
    @objc func lastPage(_ sender: UIBarButtonItem) {
        self.scrollToPage(.last, animated: true)
    }
    
    
    
    // MARK: PageboyViewControllerDataSource
    func numberOfPages(forBarStyle style: TabmanBar.Style) -> Int {
        return (self.products?.count)!
    }
    
    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.bar.appearance = PresetAppearanceConfig.forStyle(TabmanBar.Style.bar, currentAppearance: self.bar.appearance)
        var viewControllers = [UIViewController]()
        var tabBarItems = [TabmanBarItem]()
        for i in 0 ..< self.numberOfPages(forBarStyle: self.bar.style) {
            let viewController = storyboard.instantiateViewController(withIdentifier: "ChildViewController") as! ChildViewController
            viewController.index = i + 1
            print("Id number: ", self.products?[i].idNumber ?? 0)
            viewController.categoryID = self.products?[i].idNumber ?? 0
            
            
            //tabBarItems.append(TabmanBarItem(title: String(format: "Page No. %i", viewController.index!)))
            //            tabBarItems.append(TabmanBarItem(image: UIImage(named: "ic_home")!))
            tabBarItems.append(TabmanBarItem(title:(self.products?[i].name)!))
          //  tabBarItems.append(CustomTabManBar(title:(self.products?[i].name)!))
            viewControllers.append(viewController)
        }
        
        
        self.bar.items = tabBarItems
        return viewControllers
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        
        if selectedTab != 0 {
            return PageIndex.at(index: selectedTab! - 1)
            
        }
        return nil
    }
    
    // MARK: PageboyViewControllerDelegate
    
    private var targetIndex: Int?
    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
                                        willScrollToPageAtIndex index: Int,
                                        direction: PageboyViewController.NavigationDirection,
                                        animated: Bool) {
        super.pageboyViewController(pageboyViewController,
                                    willScrollToPageAtIndex: index,
                                    direction: direction,
                                    animated: animated)
        
        self.targetIndex = index
    }
    
    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
                                        didScrollToPosition position: CGPoint,
                                        direction: PageboyViewController.NavigationDirection,
                                        animated: Bool) {
        super.pageboyViewController(pageboyViewController,
                                    didScrollToPosition: position,
                                    direction: direction,
                                    animated: animated)
        
        
    }
    
    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
                                        didScrollToPageAtIndex index: Int,
                                        direction: PageboyViewController.NavigationDirection,
                                        animated: Bool) {
        super.pageboyViewController(pageboyViewController,
                                    didScrollToPageAtIndex: index,
                                    direction: direction,
                                    animated: animated)
        
        self.targetIndex = nil
    }
    
    
    
    
    
    //Adding category data
    func loadFirstSpecies() {
        
        CategorySpecies.getSpecies({ result in
            if let error = result.error {
                // TODO: improved error handling
                let alert = UIAlertController(title: "Error", message: "Could not load first species :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.setData(result.value)
            
        })
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        
        if self.popTip.isVisible {
            self.popTip.hide()
        }else{
            self.notificationConfig()
        }
        
        
        

    }
     
    func notificationConfig(){
    
       // self.popTip.shouldDismissOnTap = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier :"NotificationViewController") as! NotificationViewController
         
        let screenWidth  = UIScreen.main.fixedCoordinateSpace.bounds.width
        let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height


        addChildViewController(controller)
        controller.view.frame = CGRect(x: 0, y:0, width: screenWidth - 50, height: screenHeight - 300)
        let butnFrame: UIView = notificationBtn.value(forKey: "view") as! UIView
        popTip.showCustomView(controller.view, direction: AMPopTipDirection.down, in: self.view, fromFrame: butnFrame.frame)
        
        
    
    }
    
    func setData(_ wrapper: CategoryListWrapper?){
    
        self.productWrapper = wrapper
        if self.products == nil {
            self.products = self.productWrapper?.category
        } else if self.productWrapper != nil && self.productWrapper!.category != nil {
            self.products = self.products! + self.productWrapper!.category!
        }
        
        self.dataSource = self
    }

}
