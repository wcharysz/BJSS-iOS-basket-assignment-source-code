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
	

    override func viewDidLoad() {
        dataSource = ShoppingListDataSource()
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
			let itemNameTextField = alertController.textFields![0] as! UITextField
			let item = ShoppingListItem(name: itemNameTextField.text)
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
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
		}
		alertController.addAction(cancelAction)
		
		
		self.presentViewController(alertController, animated: true) {
		}
	}
	
		
	// MARK: UITextFieldDelegate
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		let newLength = count(textField.text) + count(string) - range.length
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
		
		if let i = item {
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
	
	
	
	// MARK: UITableViewControllerDelegate
	
	
	
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

