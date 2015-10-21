//
//  ShoppingListTableViewController.swift
//  ShoppingList
//
//  Created by Slawomir Trybus
//  Copyright (c) 2015 SlawekTrybus. All rights reserved.
//

import UIKit



enum EditModeEnum {
	case EditMode
	case NormalMode
	
	func switchMode() -> EditModeEnum {
		switch self {
			case .EditMode: return EditModeEnum.NormalMode
			case .NormalMode: return .EditMode
		}
	}
	
}


class ShoppingListTableViewController: UITableViewController, UITextFieldDelegate, ShoppingListTableViewCellDelegate {
	
	let kItemNameMaximumLength = 20
	
	@IBOutlet weak var editModeButtonItem: UIBarButtonItem!

    var dataSource: ShoppingListDataSource?
	var mode = EditModeEnum.NormalMode

    var currencyArray: [String]?

    override func viewDidLoad() {
        dataSource = ShoppingListDataSource()
    }

    @IBAction func checkoutBasket(sender: AnyObject) {
        
        var allItems: [ShoppingListItem] = Array()
        
        if let itemsInSection0 = dataSource?.itemsInSection(0) {
            allItems.appendContentsOf(itemsInSection0)
        }
        
        if let itemsInSection1 = dataSource?.itemsInSection(1) {
            allItems.appendContentsOf(itemsInSection1)
        }
        
        
        var totalSum: Float = 0
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormatter.currencyCode = "GBP"
        numberFormatter.lenient = true
        //Set local settings to UK
        numberFormatter.locale = NSLocale(localeIdentifier: "en_UK")
        
        for item: ShoppingListItem in allItems {
            
            //Clean the price string
            
            if let price = item.price {
                
                print("Price 1 ",price.removePriceDescription())
                var cleanPrice = price.removePriceDescription()

                //Check for pence
                if cleanPrice.hasSuffix("p") {
                    cleanPrice = String(cleanPrice.characters.dropLast())
                    
                    //Change to Pound
                    cleanPrice = "£0." + cleanPrice
                }
                
                if let priceNumber = numberFormatter.numberFromString(cleanPrice)?.floatValue {
                    totalSum += priceNumber
                } else {
                    //Check if the user entered pure digits
                    
                    // Create an `NSCharacterSet` set which includes everything *but* the digits
                    let inverseSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
                    
                    // At every character in this "inverseSet" contained in the string,
                    // split the string up into components which exclude the characters
                    // in this inverse set
                    let components = cleanPrice.componentsSeparatedByCharactersInSet(inverseSet)
                    
                    // Rejoin these components
                    let filtered = components.joinWithSeparator("")
                    
                    if cleanPrice == filtered {
                        totalSum += Float(cleanPrice)!
                    }
                }
            }
        }
        
        let alertController = UIAlertController(title: "Total Amount", message: String(format: "Total price in basket: £%.02f", totalSum), preferredStyle: UIAlertControllerStyle.Alert)

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        
        
        let showCurrencyList = UIAlertAction(title: "Currencies", style: .Default) { (action)  in
            
            NetworkManager.sharedInstance.getLatestExchangeRateForCurrency(Currency.GBP, completion: { (rates) -> () in
                
                if let currencyRates = rates {

                    if let names = currencyRates.rates {
                        
                        self.currencyArray = Array(names.keys)
                        
                        let localisedCurrencyNames = self.currencyArray?.map({ (name) -> String in
                            
                            return NSLocale(localeIdentifier: "en_UK").displayNameForKey(NSLocaleCurrencyCode, value: name)!
                        })
                        
                        
                        ActionSheetStringPicker.showPickerWithTitle("Currencies", rows: localisedCurrencyNames, initialSelection: 0, doneBlock: { (picker, selectedIndex, selectedValue) -> Void in
                            
                            if let currencyNames = self.currencyArray {
                                
                                let name = currencyNames[selectedIndex]
                                let currencyRate = names[name]
                                self.showAlertWithTotalPrice((currency: name, exchangeRate: currencyRate!, totalSum: totalSum))
                            }
                            
                            }, cancelBlock: { (picker) -> Void in
                                
                            }, origin: self.view)
                    }
                }
                
            })
        }
    
        alertController.addAction(showCurrencyList)
        
        self.presentViewController(alertController, animated: true) {
        }
    }
    

	@IBAction func editList(sender: AnyObject) {
		self.mode = self.mode.switchMode()
		
		switch self.mode {
		case .NormalMode:
			self.editModeButtonItem.title = "Edit"
		case .EditMode:
			self.editModeButtonItem.title = "Done"
		}
		self.tableView.setEditing(self.mode == .EditMode, animated: true)
	}

	
	@IBAction func addItem(sender: AnyObject) {
		let alertController = UIAlertController(title: "New item", message: "Please, add new item to the list", preferredStyle: .Alert)

		let newItemAction = UIAlertAction(title: "Add", style: .Default) { [unowned self] (action) in
			let itemNameTextField = alertController.textFields![0]
            let priceTextField = alertController.textFields![1]
			let item = ShoppingListItem(name: itemNameTextField.text!, price: priceTextField.text!)
			self.dataSource?.insertItem(item, atIndexPath: NSIndexPath(forRow: 0, inSection: 0))
			self.tableView.reloadData()
		}
        
		newItemAction.enabled = false
		alertController.addAction(newItemAction)

        alertController.addTextFieldWithConfigurationHandler { (textFieldName) in
			textFieldName.placeholder = "Name"
			textFieldName.delegate = self
			
			NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textFieldName, queue: NSOperationQueue.mainQueue()) { (notification) in
				newItemAction.enabled = textFieldName.text != ""
			}

		}
        
        alertController.addTextFieldWithConfigurationHandler { (textFieldPrice) -> Void in
            
            textFieldPrice.placeholder = "Price"
            textFieldPrice.delegate = self
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textFieldPrice, queue: NSOperationQueue.mainQueue()) { (notification) in
                newItemAction.enabled = textFieldPrice.text != ""
            }
            
        }
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
		}
		alertController.addAction(cancelAction)
		
		
		self.presentViewController(alertController, animated: true) {
		}
	}
	
    func showAlertWithTotalPrice(newRate: (currency: String, exchangeRate: NSNumber, totalSum: Float)) {
        
        
        let newSum = newRate.totalSum * newRate.exchangeRate.floatValue
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormatter.currencyCode = newRate.currency
        numberFormatter.lenient = true
        
        let alertController = UIAlertController(title: String(format: "Total Sum In %@", NSLocale(localeIdentifier: "en_UK").displayNameForKey(NSLocaleCurrencyCode, value: newRate.currency)!), message: numberFormatter.stringFromNumber(NSNumber(float: newSum)), preferredStyle: UIAlertControllerStyle.Alert)
        
        
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        
        self.presentViewController(alertController, animated: true) {
        }
        
        
    }
		
	// MARK: UITextFieldDelegate
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		let newLength = textField.text!.characters.count + string.characters.count - range.length
		return (newLength > kItemNameMaximumLength) ? false : true
	}
	
	
	// MARK: UITableViewControllerDataSource
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return dataSource!.numberOfSections
	}


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource!.numberOfItemsInSection(section) ?? 0
    }
	
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cellIdentifier = "ShoppingListCell"
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ShoppingListTableViewCell
		
		let section = indexPath.section
		let row = indexPath.row
		let itemsInSection = dataSource?.numberOfItemsInSection(section)
		
		cell.nameLabel.text = dataSource!.itemAtIndexPath(indexPath)?.name
        
        if let priceString = dataSource!.itemAtIndexPath(indexPath)?.price {
            
            cell.priceLabel.text = priceString
        }
        


		let topItemColor: UIColor
		let bottomItemColor: UIColor
		if indexPath.section == 0 {
			topItemColor = UIColor(hexColor: 0x00A29E)
			bottomItemColor = UIColor(hexColor: 0x00C5BF)
		} else {
			topItemColor = UIColor(hexColor: 0x999999)
			bottomItemColor = UIColor(hexColor: 0xAAAAAA)
		}
		
		let colorPosition = Float(row + 1) / Float(itemsInSection!)
		cell.backgroundColor = topItemColor.gradientColorOnPosition(colorPosition, toColor: bottomItemColor)
		cell.state = (section == 0 ? .TODO : .DONE)
		cell.delegate = self
		cell.indexPath = indexPath

		return cell
	}

	// MARK: UITableViewControllerDelegate
    
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return dataSource!.sectionTitles[section]
	}
	

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			dataSource?.removeItemAtIndexPath(indexPath)
			tableView.reloadData()
			self.editModeButtonItem.enabled = true
		}
	}
	
	
	override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	
	
	override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
		let item = dataSource?.itemAtIndexPath(fromIndexPath)
		
		if let _ = item {
			dataSource?.moveItemFromIndexPath(fromIndexPath, toIndexPath: toIndexPath)
			tableView.reloadData()
		}
	}
	
	
	override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
		self.editModeButtonItem.enabled = false
	}

	override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
		self.editModeButtonItem.enabled = true
	}
	
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
	}
	
	
	// MARK: ShoppingListTableViewCellDelegate
	
	func shoppingItemDidCheckWithIndexPath(indexPath: NSIndexPath) {
		if indexPath.section == 0 {
			dataSource?.moveItemFromIndexPath(indexPath, toIndexPath: NSIndexPath(forRow: 0, inSection: 1))
		} else {
			dataSource?.moveItemFromIndexPath(indexPath, toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
		}
		tableView.reloadData()
	}
	
	
}

