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
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        for item: ShoppingListItem in allItems {
            
            if let price = item.price {
                
                //if let cleanPrice = numberFormatter.numberFromString(price.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator(""))?.floatValue {
                print("%f", price.stringWithNonDigitsRemoved())
                if let cleanPrice = numberFormatter.numberFromString(price.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator(""))?.floatValue {
                    totalSum += Float(cleanPrice)
                }
            }
        }
        
        let alertController = UIAlertController(title: "Total Amount", message: String(format: "Total price in basket: %.02f", totalSum), preferredStyle: UIAlertControllerStyle.Alert)

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        let showCurrencyList = UIAlertAction(title: "Currencies", style: .Default) { (action)  in
            
            NetworkManager.sharedInstance.getLatestExchangeRateForCurrency(Currency.GBP, completion: { (rates) -> () in
                
                if let currencyRates = rates {

                    if let names = currencyRates.rates {
                        
                        self.currencyArray = Array(names.keys)

                        ActionSheetStringPicker.showPickerWithTitle("Currencies", rows: self.currencyArray, initialSelection: 0, doneBlock: { (picker, selectedIndex, selectedValue) -> Void in
                            
                            if let name = selectedValue as? String {
                                let currencyRate = names[name]
                                self.showAlertWithTotalPrice((currency: name, exchangeRate: currencyRate!))
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

		alertController.addTextFieldWithConfigurationHandler { (textField) in
			textField.placeholder = "Name"
			textField.delegate = self
			
			NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
				newItemAction.enabled = textField.text != ""
			}

		}
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
            textField.placeholder = "Price"
            textField.delegate = self
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                newItemAction.enabled = textField.text != ""
            }
            
        }
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
		}
		alertController.addAction(cancelAction)
		
		
		self.presentViewController(alertController, animated: true) {
		}
	}
	
    func showAlertWithTotalPrice(newRate: (currency: String, exchangeRate: NSNumber)) {
        
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

