//
//  MainViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/23/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import Material

class MainViewController: PageTabBarController {
    open override func prepare() {
        super.prepare()
        
        delegate = self
        preparePageTabBar()
    }
}

extension MainViewController {
    fileprivate func preparePageTabBar() {
        pageTabBarAlignment = .top
        pageTabBar.dividerColor = nil
        pageTabBar.lineColor = tabSelectedColor
        pageTabBar.lineAlignment = .bottom
        pageTabBar.backgroundColor = tabBGColor
                
    }
}

extension MainViewController: PageTabBarControllerDelegate {
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
        print("pageTabBarController", pageTabBarController, "didTransitionTo viewController:", viewController)
    }
}
