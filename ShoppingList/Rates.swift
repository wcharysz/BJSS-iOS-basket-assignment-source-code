//
//  Rates.swift
//  ShoppingList
//
//  Created by User  on 18.10.2015.
//  Copyright © 2015 Wojciech Charysz. All rights reserved.
//

import Foundation


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