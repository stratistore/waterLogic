//
//  Bucket.swift
//  WaterLogic
//
//  Created by dev on 24/02/2016.
//  Copyright © 2016 dev. All rights reserved.  
//

import UIKit

class Bucket: NSObject {
	// A text description of this item.
	var text: String

	// A text description of this last action taken eith this bucket.
	var lastAction: String

	// An Int value that determines the capacity of this bucket.
	var capacity: Int

	// An Int value that determines the current amount of water in this bucket.
	var currentAmount: Int

	// An Int value that determines the available capacity of this bucket.
	var  availableCapacity: Int

	//
	var filledFirstFlag:Bool

	// Returns a Bucket initialized with the given text.
	init(text: String, capacity: Int) {
		self.text = text
		self.lastAction = "INIT    "
		self.capacity = capacity
		self.currentAmount = 0
		self.availableCapacity = self.capacity - self.currentAmount
		self.filledFirstFlag = false
		
	}
}
