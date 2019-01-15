//
//  ProductSpecies.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/24/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//
import Foundation
import UIKit
import Alamofire

class ProductListWrapper{
    var product:[ProductSpecies]?
    var total: Int?
    var per_page: Int?
    var current_page: Int?
    var last_page: Int?
    fileprivate var next_page_url: String?
    fileprivate var prev_page_url: String?
    var from: Int?
    var to: Int?
    
}

enum ProductFields: String {
    case ID = "id"
    case Name = "name"
    case Image = "image"
    case Size = "size"
    case Price = "price"
    case CategoryID = "category_id"
    case Discount = "discount"
}

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}



class ProductSpecies {
    var idNumber: Int?
    var categoryID: Int?
    var name: String?
    var image: String?
    var size: String?
    var price: String?
    var discount: Int?
    var quantity: Int?
    
    required init(json: [String:Any]){
        self.idNumber = json[ProductFields.ID.rawValue] as? Int
        self.categoryID = json[ProductFields.CategoryID.rawValue] as? Int
        self.name = json[ProductFields.Name.rawValue] as? String
        self.image = json[ProductFields.Image.rawValue] as? String
        self.size = json[ProductFields.Size.rawValue] as? String
        self.price = json[ProductFields.Price.rawValue] as? String
        self.discount = json[ProductFields.Discount.rawValue] as? Int
    }
    
    init(productID:Int, categoryID: Int,name: String, size: String, price: String, discount:Int, quantity:Int, image:String) {
        self.idNumber = productID
        self.name = name
        self.categoryID = categoryID
        self.size = size
        self.price = price
        self.discount = discount
        self.quantity = quantity
        self.image = image
    }
    
    
    // MARK: Endpoints
    
    class func endpointForID(_ id: Int) -> String {
        
        return "https://swapi.co/api/species/\(id)"
        
    }
    
    class func endpointForCategory(_ id: Int) -> String {
        
        return productByCategoryURL + "/\(id)"
        
    }
    
    // MARK: CRUD
    
    // GET / Read single species
    
    class func speciesByID(_ id: Int, completionHandler: @escaping (Result<ProductSpecies>) -> Void) {
        
        let _ = Alamofire.request(ProductSpecies.endpointForID(id))
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    completionHandler(.failure(error))
                    
                    return
                    
                }
                
                let speciesResult = ProductSpecies.speciesFromResponse(response)
                
                completionHandler(speciesResult)
                
        }
    }
    
    
    // GET / Read all species
    
    fileprivate class func getSpeciesAtPath(_ path: String, completionHandler: @escaping (Result<ProductListWrapper>) -> Void) {
        
        // make sure it's HTTPS because sometimes the API gives us HTTP URLs
        
        guard var urlComponents = URLComponents(string: path) else {
            
            let error = BackendError.urlError(reason: "Tried to load an invalid URL")
            
            completionHandler(.failure(error))
            
            return
            
        }
        
        urlComponents.scheme = "http"
        
        guard let url = try? urlComponents.asURL() else {
            
            let error = BackendError.urlError(reason: "Tried to load an invalid URL")
            
            completionHandler(.failure(error))
            
            return
            
        }
        
        let _ = Alamofire.request(url)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    completionHandler(.failure(error))
                    
                    return
                    
                }
                
                let speciesWrapperResult = ProductSpecies.speciesArrayFromResponse(response)
                
                completionHandler(speciesWrapperResult)
                
        }
        
    }
    
    
    
    class func getSpecies(_ completionHandler: @escaping (Result<ProductListWrapper>) -> Void, _ id: Int) {
        
        getSpeciesAtPath(ProductSpecies.endpointForCategory(id), completionHandler: completionHandler)
        
    }
    
    
    
    class func getMoreSpecies(_ wrapper: ProductListWrapper?, completionHandler: @escaping (Result<ProductListWrapper>) -> Void) {
        
        guard let nextURL = wrapper?.next_page_url else {
            
            let error = BackendError.objectSerialization(reason: "Did not get wrapper for more species")
            
            completionHandler(.failure(error))
            
            return
            
        }
        
        getSpeciesAtPath(nextURL, completionHandler: completionHandler)
        
    }
    
    
    
    private class func speciesFromResponse(_ response: DataResponse<Any>) -> Result<ProductSpecies> {
        
        guard response.result.error == nil else {
            
            // got an error in getting the data, need to handle it
            
            print(response.result.error!)
            
            return .failure(response.result.error!)
            
        }
        
        
        
        // make sure we got JSON and it's a dictionary
        
        guard let json = response.result.value as? [String: Any] else {
            
            print("didn't get species object as JSON from API")
            
            return .failure(BackendError.objectSerialization(reason:
                
                "Did not get JSON dictionary in response"))
            
        }
        
        
        
        let species = ProductSpecies(json: json)
        
        return .success(species)
        
    }
    
    
    
    private class func speciesArrayFromResponse(_ response: DataResponse<Any>) -> Result<ProductListWrapper> {
        
        guard response.result.error == nil else {
            
            // got an error in getting the data, need to handle it
            
            print(response.result.error!)
            
            return .failure(response.result.error!)
            
        }
        
        
        
        // make sure we got JSON and it's a dictionary
        
        guard let json = response.result.value as? [String: Any] else {
            
            print("didn't get species object as JSON from API")
            
            return .failure(BackendError.objectSerialization(reason:
                
                "Did not get JSON dictionary in response"))
            
        }
        
        
        
        let wrapper:ProductListWrapper = ProductListWrapper()
        
        wrapper.next_page_url = json["next_page_url"] as? String
        
        wrapper.prev_page_url = json["prev_page_url"] as? String
        
        wrapper.total = json["total"] as? Int
        
        
        
        var allSpecies: [ProductSpecies] = []
        
        if let results = json["data"] as? [[String: Any]] {
            
            for jsonSpecies in results {
                
                let species = ProductSpecies(json: jsonSpecies)
                
                allSpecies.append(species)

      }

    }

    wrapper.product = allSpecies

    return .success(wrapper)

  }
}


class ImageSearchResult {
    let imageURL:String?
    let source:String?
    let attributionURL:String?
    var image:UIImage?
    
    required init(anImageURL: String?, aSource: String?, anAttributionURL: String?) {
        imageURL = anImageURL
        source = aSource
        attributionURL = anAttributionURL
    }
    
    func fullAttribution() -> String {
        var result:String = ""
        if attributionURL != nil && attributionURL!.isEmpty == false {
            result += "Image from \(attributionURL!)"
        }
        if source != nil && source!.isEmpty == false  {
            if result.isEmpty {
                result += "Image from "
            }
            result += " \(source!)"
        }
        return result
    }
}


