//
//  NetworkManager.swift
//  ShoppingList
//
//  Created by User  on 18.10.2015.
//  Copyright © 2015 SlawekTrybus. All rights reserved.
//

import Foundation


class NetworkManager {

    static let sharedInstance = NetworkManager()
    
    let fixerURLString = "https://api.fixer.io"
    
    func getLatestExchangeRateForCurrency(base: Currency, completion:(Rates?) -> ()) {
        
        Alamofire.manager.request(.GET, fixerURLString + String(format: "/latest?base=%@", base.rawValue)).responseObject { (response: Rates?, error: ErrorType?) -> Void in
            completion(response)
        }
    }
}