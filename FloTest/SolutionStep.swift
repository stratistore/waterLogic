//
//  SolutionStep.swift
//  FloTest
//
//  Created by dev on 28/02/2016.
//  Copyright © 2016 dev. All rights reserved.
//

import UIKit
/**
This is a TableViewCell used to display a section in the solution.

Help:
* https://youtu.be/ZIwaIEfPAh8?t=1h1m10s
*/
class SolutionStep: UITableViewCell {

	//MARK: Public API
	var step:ActionItem? {
		didSet{
			title.text = step?.text
			updateUI()
		}
	}
	@IBOutlet weak var topImage: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var subTitle: UILabel!
	@IBOutlet weak var detail: UITextView!
	@IBOutlet weak var stepImage: UIImageView!

	func updateUI(){
print("REFRESH")
	}
}
