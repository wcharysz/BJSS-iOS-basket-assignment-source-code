//
//  ShoppingListTableViewCell.swift
//  ShoppingList
//
//  Created by Slawomir Trybus
//  Copyright (c) 2015 SlawekTrybus. All rights reserved.
//

import UIKit


protocol ShoppingListTableViewCellDelegate: class {
	func shoppingItemDidCheckWithIndexPath(let indexPath: NSIndexPath) -> Void
}


class ShoppingListTableViewCell: UITableViewCell {

	weak var delegate: ShoppingListTableViewCellDelegate?
	var indexPath: NSIndexPath?
	@IBOutlet weak var tickButton: UIButton!
	@IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
	
	var state = ShoppingListItemState.TODO {
		didSet {
			switch state {
			case .TODO: tickButton.setImage(UIImage(named: "tickNormalIcon"), forState: UIControlState.Normal)
			case .DONE: tickButton.setImage(UIImage(named: "tickCheckedIcon"), forState: UIControlState.Normal)
			}
		}
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	@IBAction func itemChecked(sender: UIButton) {
		if let d = delegate, let ip = self.indexPath {
			d.shoppingItemDidCheckWithIndexPath(ip)
		}
	}
	
}
