//
//  PresetAppearanceConfig.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/26/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import Tabman

class PresetAppearanceConfig: Any {
        
        static func forStyle(_ style: TabmanBar.Style, currentAppearance: TabmanBar.Appearance?) -> TabmanBar.Appearance? {
            let appearance = currentAppearance ?? TabmanBar.Appearance.defaultAppearance
            
            
            switch style {
                
            case .bar:
                appearance.style.background = .solid(color: tabBGColor)
                appearance.indicator.color = tabSelectedColor
                appearance.state.selectedColor = tabSelectedColor
                appearance.state.color = tabUnSelectedColor
                appearance.indicator.compresses = true
                appearance.layout.interItemSpacing = 50.0
                appearance.text.font = UIFont.init(name: "PT Sans", size: 16)
                appearance.text.font = UIFont.boldSystemFont(ofSize: 16)
                appearance.indicator.lineWeight = .thick
                
            case .buttonBar:
                appearance.state.color = UIColor.white.withAlphaComponent(0.6)
                appearance.state.selectedColor = UIColor.white
                appearance.style.background = .blur(style: .light)
                appearance.indicator.color = tabSelectedColor
                appearance.layout.itemVerticalPadding = 16.0
                appearance.indicator.lineWeight = .normal
                
            case .blockTabBar:
                appearance.state.color = UIColor.white.withAlphaComponent(0.6)
                appearance.state.selectedColor = tabSelectedColor
                appearance.style.background = .solid(color: UIColor.white.withAlphaComponent(0.3))
                appearance.indicator.color = UIColor.white.withAlphaComponent(0.8)
                
            default:
                appearance.style.background = .blur(style: .light)
            }
            
            return appearance
        }


}
