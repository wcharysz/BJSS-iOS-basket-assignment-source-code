//
//  ShoppingListTests.swift
//  ShoppingListTests
//
//  Created by Wojciech Charysz on 21.10.15.
//  Copyright © 2015 SlawekTrybus. All rights reserved.
//

import XCTest
@testable import ShoppingList

class ShoppingListTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDownloadingExchangeRates() {
        NetworkManager.sharedInstance.getLatestExchangeRateForCurrency(Currency.GBP) { (rates) -> () in
            
            XCTAssertNotNil(rates)

            //Check if currency base is the same
            XCTAssertEqual(rates?.base, Currency.GBP.rawValue)
            
            //Check if the date is the latest possible
            let today = NSDate()
        
            if let ratesDate = rates?.date {
                let isDateTheSame = NSCalendar.currentCalendar().compareDate(today, toDate: ratesDate, toUnitGranularity: NSCalendarUnit.Day)
                
                XCTAssertTrue(isDateTheSame == .OrderedSame)
            } else {
                print("Missing rate's date")
                XCTAssertTrue(false)
            }
            

            
            //Check if we get exchange rates
            
            if let exchangeRates = rates?.rates {
                
                for (currencyName, currencyRate) in exchangeRates {
                    
                    switch currencyName {
                    case Currency.AUD.rawValue:
                        fallthrough
                    case Currency.BGN.rawValue:
                        fallthrough
                    case Currency.BRL.rawValue:
                        fallthrough
                    case Currency.CAD.rawValue:
                        fallthrough
                    case Currency.CHF.rawValue:
                        fallthrough
                    case Currency.CNY.rawValue:
                        fallthrough
                    case Currency.CZK.rawValue:
                        fallthrough
                    case Currency.DKK.rawValue:
                        fallthrough
                    case Currency.GBP.rawValue:
                        fallthrough
                    case Currency.HKD.rawValue:
                        fallthrough
                    case Currency.HRK.rawValue:
                        fallthrough
                    case Currency.HUF.rawValue:
                        fallthrough
                    case Currency.IDR.rawValue:
                        fallthrough
                    case Currency.ILS.rawValue:
                        fallthrough
                    case Currency.INR.rawValue:
                        fallthrough
                    case Currency.JPY.rawValue:
                        fallthrough
                    case Currency.KRW.rawValue:
                        fallthrough
                    case Currency.MXN.rawValue:
                        fallthrough
                    case Currency.MYR.rawValue:
                        fallthrough
                    case Currency.NOK.rawValue:
                        fallthrough
                    case Currency.NZD.rawValue:
                        fallthrough
                    case Currency.PHP.rawValue:
                        fallthrough
                    case Currency.PLN.rawValue:
                        fallthrough
                    case Currency.RON.rawValue:
                        fallthrough
                    case Currency.RUB.rawValue:
                        fallthrough
                    case Currency.SEK.rawValue:
                        fallthrough
                    case Currency.SGD.rawValue:
                        fallthrough
                    case Currency.THB.rawValue:
                        fallthrough
                    case Currency.TRY.rawValue:
                        fallthrough
                    case Currency.USD.rawValue:
                        fallthrough
                    case Currency.ZAR.rawValue:
                        XCTAssertTrue(currencyRate.floatValue > 0)
                        break
                    default:
                        print("Unknown currency")
                        XCTAssertTrue(false)
                        break
                    }
                }
                
            } else {
                print("Missing exchange rates")
                XCTAssertTrue(false)
            }
            
        }
    }
}
