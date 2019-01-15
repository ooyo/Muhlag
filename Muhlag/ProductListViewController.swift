//
//  ProductListViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/23/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import Material
import Alamofire

class ProductListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    internal var category: String
    internal var categoryTitle: String
    internal var categoryID: Int?
    
    var products:[ProductSpecies]?
    var productWrapper: ProductListWrapper?
    var isLoadingProduct = false
    var imageCache:Dictionary<String, ImageSearchResult?>?
    
    @IBOutlet weak var tableView: UITableView!
    required init?(coder aDecoder: NSCoder) {
        category = ""
        categoryTitle = ""
        categoryID = 0
        super.init(coder: aDecoder)
        preparePageTabBarItem()
    }
    
    init(category: String, categoryTitle: String, categoryID: Int) {
        self.category = category
        self.categoryTitle = categoryTitle
        self.categoryID = categoryID
        super.init(nibName: nil, bundle: nil)
        preparePageTabBarItem()
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
       // view.backgroundColor = Color.red.base
        
        
        definesPresentationContext = true
        
        imageCache = Dictionary<String, ImageSearchResult>()
        
        self.loadFirstSpecies()
        
        
    }
    
    
    // MARK: Loading Species from API
    
    func loadFirstSpecies() {
        isLoadingProduct = true
        
        ProductSpecies.getSpecies({ result in
            if let error = result.error {
                // TODO: improved error handling
                self.isLoadingProduct = false
                let alert = UIAlertController(title: "Error", message: "Could not load first species :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let speciesWrapper = result.value
            self.addSpeciesFromWrapper(speciesWrapper)
            self.isLoadingProduct = false
            self.tableView?.reloadData()
        }, categoryID!)
    }
    
    func loadMoreSpecies() {
        self.isLoadingProduct = true
        if let products = self.products,
            let wrapper = self.productWrapper,
            let totalSpeciesCount = wrapper.total,
            products.count < totalSpeciesCount {
            // there are more species out there!
            ProductSpecies.getMoreSpecies(productWrapper, completionHandler: { result in
                if let error = result.error {
                    self.isLoadingProduct = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more species :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                let moreWrapper = result.value
                self.addSpeciesFromWrapper(moreWrapper)
                self.isLoadingProduct = false
                self.tableView?.reloadData()
            })
        }
    }
    
    func addSpeciesFromWrapper(_ wrapper: ProductListWrapper?)
    {
        self.productWrapper = wrapper
        if self.products == nil {
            self.products = self.productWrapper?.product
        } else if self.productWrapper != nil && self.productWrapper!.product != nil {
            self.products = self.products! + self.productWrapper!.product!
        }
    }
    
    // MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView!.dequeueReusableCell(withIdentifier: "productCell")! as UITableViewCell
        
        var arrayOfSpecies: [ProductSpecies]?
       
            arrayOfSpecies = self.products
       
        
        if arrayOfSpecies != nil && arrayOfSpecies!.count >= indexPath.row {
            let species = arrayOfSpecies![indexPath.row]
            cell.textLabel?.text = species.name
            cell.detailTextLabel?.text = " " // if it's empty or nil it won't update correctly in iOS 8, see http://stackoverflow.com/questions/25793074/subtitles-of-uitableviewcell-wont-update
            cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
            cell.imageView?.image = nil
            if let name = species.name {
                // check the cache first
                if let cachedImageResult = imageCache?[name] {
                    // TODO: custom cell with class assigned for custom view?
                    cell.imageView?.image = cachedImageResult?.image // will work fine even if image is nil
                    if let attribution = cachedImageResult?.fullAttribution(), attribution.isEmpty == false {
                        cell.detailTextLabel?.text = attribution
                    }
                } else {
                    // didn't find it, so pull it down from the web
                    // this isn't ideal since it will keep running even if the cell scrolls off of the screen
                    // if we had lots of cells we'd want to stop this process when the cell gets reused
                  /*  duckDuckGoSearchController.imageFromSearchString(name, completionHandler: {
                        result in
                        if let error = result.error {
                            print(error)
                        }
                        // TODO: persist cache between runs
                        let imageSearchResult = result.value
                        self.imageCache![name] = imageSearchResult
                        if let cellToUpdate = self.tableview?.cellForRow(at: indexPath) {
                            if cellToUpdate.imageView?.image == nil {
                                cellToUpdate.imageView?.image = imageSearchResult?.image // will work fine even if image is nil
                                cellToUpdate.detailTextLabel?.text = imageSearchResult?.fullAttribution()
                                cellToUpdate.setNeedsLayout() // need to reload the view, which won't happen otherwise since this is in an async call
                            }
                        }
                    })
 
                    */
                }
            }
            
            
                // See if we need to load more species
                let rowsToLoadFromBottom = 5;
                let rowsLoaded = self.products!.count
                if (!self.isLoadingProduct && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                    if let totalRows = self.productWrapper?.total {
                        let remainingSpeciesToLoad = totalRows - rowsLoaded;
                        if (remainingSpeciesToLoad > 0) {
                            self.loadMoreSpecies()
                        }
                    }
                }
            
        }
        
        return cell
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
      /*  if let speciesDetailVC = segue.destination as? SpeciesDetailViewController {
            // gotta check if we're currently searching
            guard let indexPath = self.tableview?.indexPathForSelectedRow else {
                return
            }
            
                speciesDetailVC.species = self.species?[indexPath.row]
            
        }*/
    }
 
    
}

extension ProductListViewController {
    fileprivate func preparePageTabBarItem() {
        pageTabBarItem.title = categoryTitle
        pageTabBarItem.pulseColor = tabSelectedColor
        pageTabBarItem.setTitleColor(tabSelectedColor, for: UIControlState.selected)
        pageTabBarItem.titleColor = tabUnSelectedColor
        
    }
}


