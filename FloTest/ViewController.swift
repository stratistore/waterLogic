//
//  ViewController.swift
//  FloTest
//
//  Created by dev on 26/02/2016.
//  Copyright © 2016 dev. All rights reserved. 
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

	// MARK: - VARIABLES
	private var completeSwitch : Bool? = nil
	//private var startingBucketSize : String! = "Large"
	private var stepNum : Int = 0
	private var solvable : Bool! = false
	private var goal : Int = 0
	private var bucket1 : Bucket = (Bucket.init(text: "B1", capacity:0))
	private var bucket2 : Bucket = (Bucket.init(text: "B2", capacity:0))
	var actionItems = [ActionItem]()


	// MARK: - OUTLETS
	@IBOutlet  var tbl_SolutionTable: UITableView!
	@IBOutlet weak var txt_Bucket1Size: UITextField!
	@IBOutlet weak var txt_Bucket2Size: UITextField!
	@IBOutlet weak var txt_TargetAmount: UITextField!
	@IBOutlet weak var btn_StartCalc: UIButton!
	@IBOutlet weak var txt_Solution1: UILabel!
	@IBOutlet weak var txt_Solution2: UILabel!
	@IBOutlet weak var txt_Instructions: UITextView!

	// MARK: -
	// MARK: * VIEW LIFECYCLE
	override func viewDidLoad() {
		super.viewDidLoad()

		// MARK: o SETUP VIEW DELEGATES & SUBVIEWS
		if(tbl_SolutionTable.dataSource == nil){
			tbl_SolutionTable.dataSource = self
			tbl_SolutionTable.delegate = self
			tbl_SolutionTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		}

		txt_Bucket1Size.delegate=self
		txt_Bucket2Size.delegate=self
		txt_TargetAmount.delegate=self

		tbl_SolutionTable.hidden = true
		tbl_SolutionTable.alpha = 0 // fix
		txt_Instructions.hidden = false




		btn_StartCalc.setTitle("PRESS WHEN READY", forState: UIControlState.Normal)

		//MARK: o SET VALUES TO MATCH DIE HARD EXAMPLE
		txt_Bucket1Size.text	= "5"
		txt_Bucket2Size.text 	= "3"
		txt_TargetAmount.text 	= "4"

		//solveIt()
	}


	// MARK: - CALCULATE BUTTON
	@IBAction func calculateSolution() {

		resetBuckets(bucket1, bucket2:bucket2)

		if (txt_Instructions.hidden == true){
			txt_Instructions.hidden = false
			tbl_SolutionTable.hidden = true
			tbl_SolutionTable.alpha = 0 //fix for issue
			txt_Solution2.hidden = false
			txt_Solution1.hidden = false
			btn_StartCalc.setTitle("CALCULATE SOLUTION", forState: UIControlState.Normal)
		}else{
			txt_Instructions.hidden = true
			tbl_SolutionTable.hidden = true
			tbl_SolutionTable.alpha = 0 //fix
			txt_Solution2.hidden = false
			txt_Solution1.hidden = false
			btn_StartCalc.setTitle("VIEW INSTRUCTIONS", forState: UIControlState.Normal)
		}
		solveIt()
	}

	// MARK: - SOLVE IT FUNCTION
	func solveIt(){
		print("SOLVEIT")
		completeSwitch = false;


		//MARK: o INIT TABLEVIEW
		if actionItems.count > 0 {
			print("UI - CLEAR OLD TABLE ROWS")
			actionItems.removeAll()
			tbl_SolutionTable.reloadData()
			return
		}

		let a:Int! = Int(txt_Bucket1Size.text!)
		let b:Int! = Int(txt_Bucket2Size.text!)
		let c:Int! = Int(txt_TargetAmount.text!)

		//MARK: o INIT BUCKETS FROM INPUT

		bucket1.capacity = a
		bucket2.capacity = b
		goal 			 = c


		//MARK: o CHECK IF SOLVABLE
		solvable = verifySolvable(bucket1,bucket2:bucket2,goal:goal)
		print("SOLVABLE ",solvable," FOR THE GOAL OF ",String(goal),", USING BUCKET SIZES OF ",String(bucket1.capacity)," AND ",String(bucket2.capacity),".\n")




		if((solvable) == true){


			//MARK: o SET BUCKETS AND GOAL AMOUNTS
			bucket1.capacity = b
			bucket2.capacity = a
			goal 			 = c
			resetBuckets(bucket1, bucket2:bucket2)

			//MARK: o FIND THE PATH TO SOLUITON 1
			print("START WITH JUG 1")
			actionItems.append(ActionItem( text:"", imageToUse: "B2" ,score:"START BY FILLING JUG 1"))


			bucket2 = self.fillBucket(bucket2)
			logStatus (bucket1, bucket2:bucket2, status:"Fill")


			self.findTheNextPathPoint(bucket1, bucket2: bucket2, goal:goal)
			print("SOLUTION 1 FOUND IN ", stepNum, " STEPS\n")

			txt_Solution1.text  = "FILLING JUG 1 FIRST TAKES "+String(stepNum)+" STEPS"

			actionItems.append(ActionItem(text:"", imageToUse: "B1", score:"SOLVED IN "+String(stepNum)+" STEPS"))
			tbl_SolutionTable.reloadData()


			//MARK: o SWITCH BUCKETS AMOUNTS
			bucket1.capacity = a
			bucket2.capacity = b
			goal 			 = c
			resetBuckets(bucket1, bucket2:bucket2)


			// MARK: o FIND THE PATH TO SOLUITON 2
			print("START PATH 2")
			actionItems.append(ActionItem( text:"", imageToUse: "B2" ,score:"NOW JUG 2 FIRST"))




			bucket2 = self.fillBucket(bucket2)
			logStatus (bucket1, bucket2:bucket2, status:"Fill")


			self.findTheNextPathPoint(bucket1, bucket2: bucket2, goal:goal)
			print("SOLUTION 2 FOUND IN ", stepNum, " STEPS\n")
			txt_Solution2.text  = "FILLING JUG 2 FIRST TAKES "+String(stepNum)+" STEPS"
			actionItems.append(ActionItem(text:"", imageToUse: "B1", score:"SOLVED IN "+String(stepNum)+" STEPS"))

			txt_Solution1.hidden = false
			txt_Solution2.hidden = false
			tbl_SolutionTable.reloadData()
			tbl_SolutionTable.hidden = false
			tbl_SolutionTable.alpha=1

		}

	}

	// MARK: - APP LOGIC
	func verifySolvable(bucket1:Bucket,bucket2:Bucket, goal:Int)->Bool {
		// MARK: CHECK FOR SOLUITONS
		let hasGCD = gcd(bucket1.capacity, bucket2Size: bucket2.capacity)
		print("CHECK FOR SOLVABLE")
		print(" bucket1 - ",bucket1.capacity)
		print(" bucket2 - ",bucket2.capacity)
		print(" goal    - ",goal)
		print(" prime   - ",hasGCD," [BUCKET SIZES MUST BE RELATIVELY PRIME (i.e. GCD = 1)]")


		// MARK: o START TESTS
		print("\nTESTS")
		txt_Solution1.text = ""
		txt_Solution2.text = ""
		txt_Solution1.hidden = false
		txt_Solution2.hidden = false

		// MARK: o CHECK THAT GOAL CAN BE CONTAINED IN THE LARGETS BUCKET
		if (goal > bucket1.capacity && goal >  bucket2.capacity){
			print("* FAIL * Goal must be smaller than the largest bucket")
			txt_Solution2.text = "* FAIL * Goal must be smaller than the largest bucket"
			return(false)
		}

		// MARK: o CHECK THAT BUCKETS ARE NOT THE SAME SIZE (UNLESS GOAL IS TOO)
		if ((bucket1.capacity == bucket2.capacity) && ((goal != bucket1.capacity) || (goal != bucket2.capacity))){
			print("* FAIL * Buckets must be different sizes")
			txt_Solution2.text = "* FAIL * Buckets must be different sizes"
			return(false)
		}

		// MARK: o CHECK FOR QUICK WIN
		if (bucket1.capacity == goal || bucket2.capacity == goal){
			print("* TOO EASY * TRY AGAIN - GOAL = BUCKET SIZE")
			txt_Solution2.text = "* TOO EASY * TRY AGAIN - GOAL = BUCKET SIZE"
			return(true)
		}

		// MARK: o CHECK THAT SIZES ARE RELATIVELY PRIME (GCD = 1)
		if (hasGCD == 1  ){ //|| bucket1.capacity - bucket2.capacity == abs(goal)
			print("TESTS PASSED - CALCULATING SOLUTIONS")
			txt_Solution2.text = "TESTS PASSED - CALCULATING SOLUTIONS"
			return(true)
		}

		txt_Solution2.text = "* FAIL - NO SOLUTION * "
		return(false)

	}

	/**
	Calculates the Next Path Point in the solution.
	- Parameter bucket1: Bucket1 Object.
	- Parameter bucket2: Bucket2 Object.
	- Parameter goal: Goal Amount Int.

	- Returns:  Bool:
	*/
	func findTheNextPathPoint( startingBucket: Bucket, var bucket2: Bucket, goal:Int) -> Bool {
		//MARK: FIND NEXT PATH POINT
		var solved = false
		while solved == false {
			if(startingBucket.currentAmount == goal || bucket2.currentAmount == goal){
				print("COMPLETE 4 UNITS in B...")
				completeSwitch = true
				return (completeSwitch)!
			}

			if(solved == false){

				// MARK: o CHECK FOR TRANSFER (TOP)
				if(bucket1.currentAmount == 0 && (solved == false)){
					// (LARGE FIRST) TRANSFER (LARGE > SMALL)
					transferBucketL2S(bucket2, bucketTo: bucket1)
					//bucket1 = self.fillBucket(bucket1)

					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:"Transfer")}

				// MARK: o CHECK FOR TRANSFER (RIGHT)
				if(bucket2.currentAmount == bucket2.capacity  && (solved == false)){
					// (LARGE FIRST) TRANSFER (SMALL > LARGE)
					transferBucketL2S(bucket2, bucketTo: bucket1)
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:"Transfer")}

				// MARK: o CHECK FOR TRANSFER (LEFT)
				if(bucket1.currentAmount > 0 && bucket1.currentAmount < bucket1.capacity && (solved == false)){
					// (LARGE FIRST) ALWAYS FILL
					bucket2 = self.fillBucket(bucket2)
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:"Fill")}

				// MARK: o CHECK FOR TRANSFER (BOTTOM)
				if(( bucket1.currentAmount == bucket1.capacity && (solved == false))){
					bucket1 = self.emptyBucket(bucket1)
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:"Empty")}


			}
		}
		return (true)
	}

	// MARK: - GET SCORE
	func getScore(bucket1:Bucket, bucket2:Bucket, goal:Int)-> Bool{

		if(bucket1.currentAmount == goal || bucket2.currentAmount == goal)
		{return (true) }
		else {return (false)}
	}

	// MARK: - ACTIONS
	func fillBucket(bucket : Bucket) -> Bucket {
		// MARK: o FILL
		bucket.currentAmount = bucket.capacity
		bucket.availableCapacity = 0
		let lastAction = "FILLED  "
		bucket.lastAction = lastAction
		//logBucketStatus(bucket)
		return bucket
	}



	func emptyBucket(bucket : Bucket) -> Bucket {
 	// MARK: o EMPTY
		bucket.currentAmount = 0
		bucket.availableCapacity = bucket.capacity
		let lastAction = "EMPTIED"
		bucket.lastAction = lastAction
		return bucket	}


	func transferBucketL2S(bucketFrom : Bucket, bucketTo : Bucket ){
		// MARK: o TRANSFER
		bucketFrom.lastAction = "XFER OUT"
		bucketTo.lastAction   = "XFER IN "

		if(bucketFrom.currentAmount < bucketTo.availableCapacity) {

			let amountToTransfer    		= bucketFrom.currentAmount
			bucketFrom.currentAmount 		= bucketFrom.currentAmount     - amountToTransfer
			bucketFrom.availableCapacity 	= bucketFrom.capacity 		   - bucketFrom.currentAmount
			bucketTo.currentAmount   		= bucketTo.currentAmount       + amountToTransfer
			bucketTo.availableCapacity   	= bucketTo.capacity            - bucketTo.currentAmount


		}
		else {
			let amountToTransfer    		= bucketFrom.currentAmount     - (bucketFrom.currentAmount - bucketTo.availableCapacity)
			bucketFrom.currentAmount 		= bucketFrom.currentAmount     - amountToTransfer
			bucketFrom.availableCapacity 	= bucketFrom.capacity 		   - bucketFrom.currentAmount
			bucketTo.currentAmount   		= bucketTo.currentAmount       + amountToTransfer
			bucketTo.availableCapacity   	= bucketTo.capacity            - bucketTo.currentAmount


		}
	}

	// MARK: - LOG ACTIONS
	func logStatus (bucket1:Bucket, bucket2:Bucket, status:String){
		// MARK: o PRINT LOG TO THE DEBUG SCREEN
		stepNum = stepNum + 1
		print("ACTION   - STEP ",stepNum, "\tSTARTING BUCKET ", "\t[",status, "]")
		logBucketStatus(bucket1)
		logBucketStatus(bucket2)
		print("\n")

		// MARK: o ADD ACTION ITEM TO THE SOLUTION COLLECTION (TABLE)
		let scoreMessage 	= String(bucket1.currentAmount)+"|"+String(bucket2.currentAmount)
		let stepMessage 	= "\t"+String(stepNum)
		let statusMessage 	= " - "+status
		let lineToAdd = stepMessage+statusMessage
		actionItems.append(ActionItem(text: lineToAdd, imageToUse: status, score:scoreMessage))
		tbl_SolutionTable.reloadData()
	}
	func logBucketStatus(bucket:Bucket){
		// MARK: o LOG BUCKET STATUS (DEBUG WINDOW ONLY)
		print(bucket.lastAction, "-",bucket.text,"      - Capacity ", bucket.capacity, "\tCurrent Amount ",bucket.currentAmount, "\tAvailable Capacity ", bucket.availableCapacity)
		bucket.lastAction = "NONE    "
	}

	// MARK: - HELPER FUNCIONS

	func resetBuckets (bucket1:Bucket, bucket2:Bucket){
		// MARK: RESET BUCKETS
		stepNum = 0
		bucket1.availableCapacity = bucket1.capacity
		bucket2.availableCapacity = bucket2.capacity
		bucket1.currentAmount = 0
		bucket2.currentAmount = 0
		bucket1.filledFirstFlag = false
		bucket2.filledFirstFlag = false
		txt_Solution1.hidden = false
		txt_Solution2.hidden = false
	}

	//MARK: - FIND GCD
	/**
	Calculates the GCD (Greatest Common Denominator) for two numbers.
	- Parameter bucket1Size: Integer representing the Size/Capacity of the first Bucket.
	- Parameter bucket2Size: Integer representing the Size/Capacity of the second Bucket.
	- Returns:  Integer - GCD of two numbers:
	*/
	func gcd(var bucket1Size : Int, var bucket2Size : Int) -> Int {
		while bucket2Size != 0 {
			(bucket1Size, bucket2Size) = (bucket2Size, bucket1Size % bucket2Size)
		}
		return abs(bucket1Size)
	}




	// MARK: -
	// MARK: * ROTATION
	override func shouldAutorotate() -> Bool {
		return true
	}

	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		if(self.txt_Instructions != nil){
			self.txt_Instructions.scrollRangeToVisible(NSMakeRange(0, 0))
		}
		return [UIInterfaceOrientationMask.LandscapeLeft,UIInterfaceOrientationMask.LandscapeRight,UIInterfaceOrientationMask.Portrait,UIInterfaceOrientationMask.PortraitUpsideDown]

	}

	// MARK: * MEMORY MANAGEMENT
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	// MARK: * TABLE VIEW DELEGATES

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return actionItems.count
	}

	func tableView(tableView: UITableView,
		cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCellWithIdentifier("scoreCell",
				forIndexPath: indexPath)
			let item = actionItems[indexPath.row]
			cell.imageView?.image = UIImage(imageLiteral: item.imageToUse)
			cell.textLabel?.text = item.text
			cell.detailTextLabel?.text = item.score //"0|1"
			return cell
	}

	// MARK: * TEXT FIELD DELEGATE
	func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
	{
		textField.resignFirstResponder()
		return true;
	}
	
	
}

