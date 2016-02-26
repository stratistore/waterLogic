//
//  ActionItem.swift
//  WaterLogic
//
//  Created by dev on 23/02/2016.
//  Copyright © 2016 dev. All rights reserved.
//

import UIKit

class ActionItem: NSObject {
	// A text description of this item.
	var text: String


	// Returns a ToDoItem initialized with the given text and default completed value.
	init(text: String) {
		self.text = text
	}
}
