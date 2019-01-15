//
//  CategorySpecies.swift
//  Muhlag
//
//  Created by Nuk3denE on 3/26/17.
//  Copyright © 2017 Tseyen-Oidov Erdenebileg. All rights reserved.
//

import UIKit
import Foundation
import Alamofire


class CategoryListWrapper{
    var category:[CategorySpecies]?
    var resultCode: String?
    
}

enum CategoryFields: String {
    case Id = "id"
    case Name = "name"
    case Product = "product"
}


class CategorySpecies {
    var idNumber: Int?
    var name: String?
    var product: Int?
    
    required init(json: [String:Any]){
        self.idNumber = json[CategoryFields.Id.rawValue] as? Int
        self.name = json[CategoryFields.Name.rawValue] as? String
        self.product = json[CategoryFields.Product.rawValue] as? Int
    }
    
    
    // MARK: Endpoints
    
    class func endpointForID(_ id: Int) -> String {
        
        return "https://swapi.co/api/species/\(id)"
        
    }
    
    class func endpointForCategory() -> String {
        
        return categoryListURL
        
    }
    
    // MARK: CRUD
    
    // GET / Read single species
    
    class func speciesByID(_ id: Int, completionHandler: @escaping (Result<CategorySpecies>) -> Void) {
        
        let _ = Alamofire.request(CategorySpecies.endpointForID(id))
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    completionHandler(.failure(error))
                    
                    return
                    
                }
                
                let speciesResult = CategorySpecies.speciesFromResponse(response)
                
                completionHandler(speciesResult)
                
        }
    }
    
    
    // GET / Read all species
    
    fileprivate class func getSpeciesAtPath(_ path: String, completionHandler: @escaping (Result<CategoryListWrapper>) -> Void) {
        
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
                
                let speciesWrapperResult = CategorySpecies.speciesArrayFromResponse(response)
                
                completionHandler(speciesWrapperResult)
                
        }
        
    }
    
    
    
    class func getSpecies(_ completionHandler: @escaping (Result<CategoryListWrapper>) -> Void) {
        
        getSpeciesAtPath(CategorySpecies.endpointForCategory(), completionHandler: completionHandler)
        
    }
    
    
    
    
    
    
    
    private class func speciesFromResponse(_ response: DataResponse<Any>) -> Result<CategorySpecies> {
        
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
        
        
        
        let species = CategorySpecies(json: json)
        
        return .success(species)
        
    }
    
    
    
    private class func speciesArrayFromResponse(_ response: DataResponse<Any>) -> Result<CategoryListWrapper> {
        
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
        
        
        
        let wrapper:CategoryListWrapper = CategoryListWrapper()
        
        
        wrapper.resultCode = json["resultCode"] as? String
        
        
        
        var allSpecies: [CategorySpecies] = []
        
        if let results = json["result"] as? [[String: Any]] {
            
            for jsonSpecies in results {
                
                let species = CategorySpecies(json: jsonSpecies)
                
                allSpecies.append(species)
                
            }
            
        }
        
        wrapper.category = allSpecies
        
        return .success(wrapper)
        
    }
}
 
