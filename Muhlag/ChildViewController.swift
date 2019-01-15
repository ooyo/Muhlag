//
//  ChildViewController.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/25/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import BubbleTransition
import DZNEmptyDataSet
import DGElasticPullToRefresh
class ChildViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet weak var label: UILabel!
    var myCart: [ProductSpecies] = []
   
    
    var products:[ProductSpecies]?
    var productWrapper: ProductListWrapper?
    var isLoadingProduct = false
    var imageCache:Dictionary<String, ImageSearchResult?>?
    
    var totalPrice: Float = 0.0
    
    @IBOutlet weak var checkOutBtn: UIButton!
     var index: Int?
    var categoryID: Int  = 0
    
    
     let transition = BubbleTransition()
    

    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Category ID: ",  categoryID!)
          checkOutBtn.layer.cornerRadius = checkOutBtn.layer.frame.size.height/2
        checkOutBtn.titleLabel?.numberOfLines = 0
        checkOutBtn.sizeToFit()
        definesPresentationContext = true
        
        imageCache = Dictionary<String, ImageSearchResult>()
        
        self.loadFirstSpecies()
        
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.white
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.loadFirstSpecies()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self?.tableView.dg_stopLoading()
            })
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(cartBGColor)
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
    }
 

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm()
        let dataSource = realm.objects(RealmCart.self).filter("status == 0")
        totalPrice = 0.0
        if dataSource.count == 0 {
            self.checkOutBtn.isHidden = true
        }else{
            self.checkOutBtn.isHidden = false
            let myCartList = realm.objects(RealmCart.self).filter("status == 0")
            
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
            self.checkOutBtn.setTitle(String(describing: totalPrice), for: UIControlState.normal)
        }
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func checkOutAction(_ sender: Any) {
       
          //  for jsonSpecies in myCart {
                
          //      print("Name:", jsonSpecies.name!)
                
          //  }
       
        performSegue(withIdentifier: "gotoCheckOut", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoCheckOut" {
            let controller = segue.destination
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .custom
        }
    }
    public override func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let realm = try! Realm()
        let dataSource = realm.objects(RealmCart.self).filter("status == 0")
       
        totalPrice = 0.0
        if dataSource.count == 0 {
            self.checkOutBtn.isHidden = true
        }else{
            self.checkOutBtn.isHidden = false
            let myCartList = realm.objects(RealmCart.self).filter("status == 0")
            
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
            self.checkOutBtn.setTitle(String(describing: totalPrice), for: UIControlState.normal)
        }

        
        transition.transitionMode = .dismiss
        transition.startingPoint = checkOutBtn.center
        transition.bubbleColor = checkOutBtn.backgroundColor!
        return transition
    }
    
    
    public override func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = checkOutBtn.center
        transition.bubbleColor = UIColor(red: 43.0/255.0, green: 38.0/255.0, blue: 43.0/255.0, alpha: 1.0) //checkOutBtn.backgroundColor!
        return transition
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
        }, categoryID)
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
    
    func addToCart(_ productSpecies: ProductSpecies){
        
        let cart = RealmCart()
        cart.categoryID = productSpecies.categoryID!
        cart.productID = productSpecies.idNumber!
        cart.name = productSpecies.name!
        cart.size = productSpecies.size!
        cart.price = productSpecies.price!
        cart.discount = productSpecies.discount!
        cart.quantity = productSpecies.quantity!
        cart.image = productSpecies.image!
        cart.status = 0
        
        let realm = try! Realm()
        let myOrder = realm.objects(RealmOrder.self)
        
        if myOrder.count > 0 {
            performSegue(withIdentifier: "havePlacedOrder", sender: nil)
        }else{
            totalPrice = 0.0
            try! realm.write {
                realm.add(cart, update:true)
                
                let myCartList = realm.objects(RealmCart.self)
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
                self.checkOutBtn.isHidden = false
                self.checkOutBtn.setTitle(String(describing: totalPrice), for: UIControlState.normal)
            }
        }
        
    }
    // MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ProductTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "productCell") as! ProductTableViewCell
        var arrayOfSpecies: [ProductSpecies]?
        
        arrayOfSpecies = self.products
        
        
        if arrayOfSpecies != nil && arrayOfSpecies!.count >= indexPath.row {
            let species = arrayOfSpecies![indexPath.row]
            
            cell.productName.text = species.name
            
            
           // let attStr = try! NSAttributedString(data: "<b> MNT </b> <del> \(species.price!) </del>".data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
           // cell.productPrice.font = cell.productPrice.font.withSize(40.0)
           // cell.productPrice.attributedText = attStr //"MNT " + species.price!
            if species.discount ?? 0 > 0 {
                let productPrice: Int32 = Int32(Float(species.price!)! * 1000)
                let discountMNT =  (productPrice / 100) * Int32(species.discount!)
                let priceCalculate = Float(productPrice - discountMNT) / 1000.0;
                
                let customView:UIView = UIView.init(frame: CGRect(x: -5, y: cell.productOldPrice.frame.size.height/2, width: cell.productOldPrice.frame.size.width + 10, height: 1))
                customView.backgroundColor = cartBGColor
                cell.productNewPrice.isHidden = false
                cell.productOldPrice.isHidden = false
                cell.productPrice.isHidden = true
                cell.productOldPrice.text = "MNT " + species.price!
                cell.productOldPrice.addSubview(customView)
                cell.productNewPrice.text = "MNT " + String(format: "%.2f", priceCalculate)
            }else{
                cell.productPrice.isHidden = false
                cell.productOldPrice.isHidden = true
                cell.productNewPrice.isHidden = true
                cell.productPrice.text = "MNT " + species.price!
            }
            
            cell.productSize.text = "(" + species.size! + ")"
            
            cell.productImageWebView.kf.indicatorType = .activity
            let imageURL = URL(string: productImagePublicURL + species.image!)
            let resource = ImageResource(downloadURL:imageURL!, cacheKey: productImagePublicURL + species.image!)
            cell.productImageWebView.kf.setImage(with: resource, options: [.transition(.fade(0.2))])

            
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
            
            cell.addToCartAction={
                
                let duration: TimeInterval = 1.0
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    cell.productButton.alpha = 0.3
                })
                
                
                

                self.addToCart(ProductSpecies(productID: species.idNumber!, categoryID: species.categoryID!, name: species.name!, size: species.size!, price: species.price!, discount: species.discount ?? 0, quantity: 1, image: species.image!))
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var shownIndexes : [IndexPath] = []

        if (shownIndexes.contains(indexPath) == false) {
            shownIndexes.append(indexPath)
            
            cell.transform = CGAffineTransform(translationX: 0, y: 10.0)
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 10, height: 10)
            cell.alpha = 0
            
            UIView.beginAnimations("rotation", context: nil)
            UIView.setAnimationDuration(0.5)
            cell.transform = CGAffineTransform(translationX: 0, y: 0)
            cell.alpha = 1
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            UIView.commitAnimations()
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110.0;//Choose your custom row height
    }
    
    
    //DZNEmptyDataSet
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "government")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor(colorLiteralRed: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    }
    
    



}
