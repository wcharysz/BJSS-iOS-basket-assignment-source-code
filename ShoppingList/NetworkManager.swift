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
    
    func getLatestExchangeRateForPoundSterling() -> Rates? {
        
        guard let jsonPath = NSBundle.mainBundle().pathForResource("SampleExchangeRates", ofType: "json")  else {
            return nil
        }
        
        do {
            let jsonData = try NSData(contentsOfFile: jsonPath, options: NSDataReadingOptions.DataReadingMapped)
            
            let rates = Mapper<Rates>().map(jsonData)
            return rates
        } catch {
            return nil
        }
    }
}