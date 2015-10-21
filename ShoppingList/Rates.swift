//
//  Rates.swift
//  ShoppingList
//
//  Created by User  on 18.10.2015.
//  Copyright © 2015 Wojciech Charysz. All rights reserved.
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

class Rates: Mappable {
    
    var base: String?
    var date: NSDate?
    var rates: [String: NSNumber]?
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        base <- map["base"]
        date <- (map["date"], CustomDateFormatTransform(formatString: "yyy-MM-dd"))
        rates <- map["rates"]
    }
    
}