//
//  StringExtensions.swift
//  ShoppingList
//
//  Created by User  on 18.10.2015.
//  Copyright © 2015 SlawekTrybus. All rights reserved.
//

import Foundation

extension String {


    func stringWithNonDigitsRemoved() -> String {
        
        let decimalDigits = NSCharacterSet.decimalDigitCharacterSet()
        
        var stringWithNonDigitsRemoved = NSMutableString(string: self)
        
        
        for var index: CFIndex = 0; index < stringWithNonDigitsRemoved.length; ++index {
            let c = stringWithNonDigitsRemoved.characterAtIndex(index)
            if (!decimalDigits.characterIsMember(c)) {
                stringWithNonDigitsRemoved.deleteCharactersInRange(NSRange(location: index, length: 1))
                index -= 1
            }
        }
        
        return String(stringWithNonDigitsRemoved)
    }
    
    func removePriceDescription() -> String {
        guard let textRange = self.rangeOfString(" ") else {
            return self
        }
        
        let intIndex = self.startIndex.distanceTo(textRange.startIndex)
        let firstSpaceIndex = self.startIndex.advancedBy(intIndex)
        
        return self.substringToIndex(firstSpaceIndex)
    }

}