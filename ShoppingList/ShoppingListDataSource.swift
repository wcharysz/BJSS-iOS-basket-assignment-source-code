//
//  ShoppingListDataSource.swift
//  ShoppingList
//
//  Created by Slawomir Trybus
//  Copyright (c) 2015 SlawekTrybus. All rights reserved.
//

import UIKit


enum ShoppingListItemState: String {
	case TODO = "new items"
	case DONE = "collected already"
}


class ShoppingListItem: NSCoder {
	var name: String
    var price: String?
    var currency: Currency?
	
	override init() {
		name = ""
	}
	
    init(name: String, price: String) {
		self.name = name
        self.price = price
	}
	
	// MARK: NSCoding
	
	required convenience init(coder decoder: NSCoder) {
		self.init()
		self.name = decoder.decodeObjectForKey("name") as! String
        
        if let price = decoder.decodeObjectForKey("price") as? String {
            self.price = price
        }
        
        if let money = decoder.decodeObjectForKey("currency") as? String {
            self.currency = Currency(rawValue: money)
        }
	}
	
	func encodeWithCoder(coder: NSCoder) {
		coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.price, forKey: "price")
        coder.encodeObject(self.currency?.rawValue, forKey: "currency")
	}
}



class ShoppingListDataSource: TableViewDataSource {

    private var sectionsAndItems: [Int: [ShoppingListItem]] = [:]


    var numberOfSections: Int {
            return sectionsAndItems.count
    }

    var sectionTitles: [String] {
        let titles = [ShoppingListItemState.TODO.rawValue, ShoppingListItemState.DONE.rawValue]
		return titles
    }

    init() {
        reloadData()
    }


    func numberOfItemsInSection(section: Int) -> Int? {
        return sectionsAndItems[section]?.count
    }

    func itemsInSection(section: Int) -> [ShoppingListItem]? {
		return sectionsAndItems[section]
    }

    subscript(section: Int) -> [ShoppingListItem]? {
		return itemsInSection(section)
	}

	func itemAtIndexPath(indexPath: NSIndexPath) -> ShoppingListItem? {
		let items: [ShoppingListItem]? = self[indexPath.section]
		return items?[indexPath.row]
	}
	
	func insertItem(item: ShoppingListItem, atIndexPath indexPath: NSIndexPath) {
		let section = indexPath.section
		let row = indexPath.row
		_ = self.sectionTitles[indexPath.section]

		sectionsAndItems[section]?.insert(item, atIndex: row)
		
		archiveData()
	}
	
	func removeItemAtIndexPath(indexPath: NSIndexPath) {
		let section = indexPath.section
		let row = indexPath.row
		_ = self.sectionTitles[indexPath.section]
		
		sectionsAndItems[section]?.removeAtIndex(row)

		archiveData()
	}
	
	func moveItemFromIndexPath(beginIndexPath: NSIndexPath, toIndexPath endIndexPath: NSIndexPath) {
		let beginSection = beginIndexPath.section
		let beginIndex = beginIndexPath.row

		let endSection = endIndexPath.section
		let endIndex = endIndexPath.row

		if beginSection == endSection {
			if var items = sectionsAndItems[beginSection] {
				let item = items[beginIndex]

				if beginIndex < endIndex {
					items.removeAtIndex(beginIndex)
					items.insert(item, atIndex: endIndex)
				} else {
					items.removeAtIndex(beginIndex)
					items.insert(item, atIndex: endIndex)
				}
				sectionsAndItems[beginSection] = items
			}
		} else {
			if var items = sectionsAndItems[beginSection], var _ = sectionsAndItems[endSection] {
				let item = items[beginIndex]
				
				removeItemAtIndexPath(beginIndexPath)
				insertItem(item, atIndexPath: endIndexPath)
			}
		}

		archiveData()
	}
	
	
    func reloadData() -> Void {
		if let arch = unarchiveData() {
			sectionsAndItems = arch
		} else {
			//sectionsAndItems = [0: [ShoppingListItem(name: "An item to take")],
			//	1: [ShoppingListItem(name: "Collected item")]]
            sectionsAndItems = [0: [ShoppingListItem(name: "Peas", price: "95p per bag"),
                                    ShoppingListItem(name: "Eggs", price: "£2.10 per dozen"),
                                    ShoppingListItem(name: "Milk", price: "£1.30 per bottle"),
                                    ShoppingListItem(name: "Beans", price: "73p per can")]]
		}
    }

	
	private func archiveData() {
		NSKeyedArchiver.archiveRootObject(sectionsAndItems, toFile: archivedDataFilePath())
	}

	
	private func unarchiveData() -> [Int: [ShoppingListItem]]? {
		return NSKeyedUnarchiver.unarchiveObjectWithFile(archivedDataFilePath()) as? [Int: [ShoppingListItem]]
	}
	
	
	private func archivedDataFilePath() -> String {
		let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
		return documentsDirectory + "/data"
	}
	
}


