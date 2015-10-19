//
//  NetworkManager.swift
//  ShoppingList
//
//  Created by User  on 18.10.2015.
//  Copyright © 2015 SlawekTrybus. All rights reserved.
//

import Foundation


enum Currency: String {
    
    case AUD = "AUD"
    case BGN = "BGN"
    case BRL = "BRL"
    case CAD = "CAD"
    case CHF = "CHF"
    case CNY = "CNY"
    case CZK = "CZK"
    case DKK = "DKK"
    case GBP = "GBP"
    case HKD = "HKD"
    case HRK = "HRK"
    case HUF = "HUF"
    case IDR = "IDR"
    case ILS = "ILS"
    case INR = "INR"
    case JPY = "JPY"
    case KRW = "KRW"
    case MXN = "MXN"
    case MYR = "MYR"
    case NOK = "NOK"
    case NZD = "NZD"
    case PHP = "PHP"
    case PLN = "PLN"
    case RON = "RON"
    case RUB = "RUB"
    case SEK = "SEK"
    case SGD = "SGD"
    case THB = "THB"
    case TRY = "TRY"
    case USD = "USD"
    case ZAR = "ZAR"
}


class NetworkManager {

    static let sharedInstance = NetworkManager()
    
    let fixerURLString = "https://api.fixer.io"
    
    func getLatestExchangeRateForCurrency(base: Currency, completion:(Rates?) -> ()) {
        
        Alamofire.manager.request(.GET, fixerURLString + String(format: "/latest?base=%@", base.rawValue)).responseObject { (response: Rates?, error: ErrorType?) -> Void in
            completion(response)
        }
    }
}