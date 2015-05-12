//
//  UIColorExtensions.swift
//  ShoppingList
//
//  Created by Slawomir Trybus
//  Copyright (c) 2015 SlawekTrybus. All rights reserved.
//

import UIKit

extension UIColor {

	convenience init(hexColor: Int, alpha: CGFloat = 1.0) {
		let red = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
		let green = CGFloat((hexColor & 0xFF00) >> 8) / 255.0
		let blue = CGFloat((hexColor & 0xFF)) / 255.0
		self.init(red:red, green:green, blue:blue, alpha:alpha)
	}
	
	func gradientColorOnPosition(onPosition: Float, toColor secondColor: UIColor) -> UIColor {

		let firstColor = self
		
		var firstColorRed: CGFloat = 0
		var firstColorGreen: CGFloat = 0
		var firstColorBlue: CGFloat = 0
		var firstColorAlpha: CGFloat = 0
		firstColor.getRed(&firstColorRed, green: &firstColorGreen, blue: &firstColorBlue, alpha: &firstColorAlpha)
		
		var secondColorRed: CGFloat = 0
		var secondColorGreen: CGFloat = 0
		var secondColorBlue: CGFloat = 0
		var secondColorAlpha: CGFloat = 0
		secondColor.getRed(&secondColorRed, green: &secondColorGreen, blue: &secondColorBlue, alpha: &secondColorAlpha)
		
		let resultRed = firstColorRed + CGFloat(onPosition) * (secondColorRed - firstColorRed);
		let resultGreen = firstColorGreen + CGFloat(onPosition) * (secondColorGreen - firstColorGreen);
		let resultBlue = firstColorBlue + CGFloat(onPosition) * (secondColorBlue - firstColorBlue);
		let resultAlpha = firstColorAlpha + CGFloat(onPosition) * (secondColorAlpha - firstColorAlpha);
		
		return UIColor(red: resultRed, green: resultGreen, blue: resultBlue, alpha: resultAlpha)
	}
	
}
