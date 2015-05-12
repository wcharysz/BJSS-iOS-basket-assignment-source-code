//
//  TableViewDataSource.swift
//  ShoppingList
//
//  Created by Slawomir Trybus
//  Copyright (c) 2015 SlawekTrybus. All rights reserved.
//

import UIKit



protocol TableViewDataSource {

	typealias Item

	var numberOfSections: Int { get }
	var sectionTitles: [String] { get }

	func numberOfItemsInSection(section: Int) -> Int?
	func itemsInSection(section: Int) -> [Item]?
	subscript(section: Int) -> [Item]? { get }
	func itemAtIndexPath(indexPath: NSIndexPath) -> ShoppingListItem?
	func insertItem(item: Item, atIndexPath indexPath: NSIndexPath)
	func removeItemAtIndexPath(indexPath: NSIndexPath)
	func moveItemFromIndexPath(beginIndexPath: NSIndexPath, toIndexPath endIndexPath: NSIndexPath)
	func reloadData() -> Void
}
