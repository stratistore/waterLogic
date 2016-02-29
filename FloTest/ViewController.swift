//
//  ViewController.swift
//  FloTest
//
//  Created by dev on 26/02/2016.
//  Copyright © 2016 dev. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	//MARK: Set Variables
	/** TEST */
	private var completeSwitch : Bool? = nil
	//private var startingBucketSize : String! = "Large"
	private var stepNum : Int = 0
	private var solvable : Bool! = false
	private var goal : Int = 0
	private var bucket1 : Bucket = (Bucket.init(text: "Large", capacity:0))
	private var bucket2 : Bucket = (Bucket.init(text: "Small", capacity:0))
	var actionItems = [ActionItem]()


	// MARK: - Outlets
	@IBOutlet  var tbl_SolutionTable: UITableView!
	@IBOutlet weak var txt_Bucket1Size: UITextField!
	@IBOutlet weak var txt_Bucket2Size: UITextField!
	@IBOutlet weak var txt_TargetAmount: UITextField!
	@IBOutlet weak var btn_StartCalc: UIButton!


	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		if(tbl_SolutionTable.dataSource == nil){
			tbl_SolutionTable.dataSource = self
			tbl_SolutionTable.delegate = self
			tbl_SolutionTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		}

		print(self.btn_StartCalc.titleLabel!.text)

		self.btn_StartCalc!.titleLabel!.text = "READY"
		btn_StartCalc.setTitle("READY", forState: UIControlState.Normal)
		print(self.btn_StartCalc.titleLabel!.text)

		tbl_SolutionTable.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
		//MARK:CONVERT INPUTS TO VALUES
		txt_Bucket1Size.text	= "5"
		txt_Bucket2Size.text 	= "3"
		txt_TargetAmount.text 	= "4"

		solveIt()
	}


	@IBAction func bucket1SizeChanged() {
		print("BUCKET 1 CHANGED SIZE")

	}

	@IBAction func CalculateSolution() {

		resetBuckets(bucket1, bucket2:bucket2)
		btn_StartCalc.setTitle("DONE", forState: UIControlState.Normal)
		solveIt()
	}


	func solveIt(){
		print("SOLVEIT")
		completeSwitch = false;




		//MARK:INIT TABLEVIEW
		if actionItems.count > 0 {
			print("REMOVE")
			actionItems.removeAll()
			tbl_SolutionTable.reloadData()
			return
		}

		let a:Int! = Int(txt_Bucket1Size.text!)
		let b:Int! = Int(txt_Bucket2Size.text!)
		let c:Int! = Int(txt_TargetAmount.text!)

		//MARK: INIT BUCKETS FROM INPUT

		bucket1.capacity = a
		bucket2.capacity = b
		goal 			 = c

		print("2")
		//MARK: CHECK IF SOLVABLE
		solvable = verifySolvable(bucket1,bucket2:bucket2,goal:goal)
		print("SOLVABLE ",solvable,"\n\nSOLUTION STEPS\n")



		if((solvable) == true){

			//MARK: INIT BUCKETS
			//startingBucketSize = "Large"
			//logStatus (bucket1, bucket2:bucket2, status: "INIT")
			print("PATH 1")

			bucket1.capacity = a
			bucket2.capacity = b
			goal 			 = c
			resetBuckets(bucket1, bucket2:bucket2)


			// MARK: BEGIN BY FILLING A BUCKET 1
			// MARK: BEGIN BY FILLING A BUCKET
			//			bucket1.filledFirstFlag = false
			//			bucket2.filledFirstFlag = true
			bucket2 = self.fillBucket(bucket2)
			logStatus (bucket1, bucket2:bucket2, status:"FILL")

			// MARK: FIND THE PATH TO SOLUITON 2
			self.findTheNextPathPoint(bucket1, bucket2: bucket2, goal:goal)
			print("SOLUTION 2 FOUND IN ", stepNum, " STEPS\n")


			print("PATH 2")

			bucket1.capacity = b
			bucket2.capacity = a
			goal 			 = c
			resetBuckets(bucket1, bucket2:bucket2)

			// MARK: BEGIN BY FILLING A BUCKET
			//			bucket1.filledFirstFlag = false
			//			bucket2.filledFirstFlag = true
			bucket2 = self.fillBucket(bucket2)
			logStatus (bucket1, bucket2:bucket2, status:"FILL")

			// MARK: FIND THE PATH TO SOLUITON 2
			self.findTheNextPathPoint(bucket1, bucket2: bucket2, goal:goal)
			print("SOLUTION 2 FOUND IN ", stepNum, " STEPS\n")
		}

	}

	func resetBuckets (bucket1:Bucket, bucket2:Bucket){
		stepNum = 0
		bucket1.availableCapacity = bucket1.capacity
		bucket2.availableCapacity = bucket2.capacity
		bucket1.currentAmount = 0
		bucket2.currentAmount = 0
		bucket1.filledFirstFlag = false
		bucket2.filledFirstFlag = false
	}


	func verifySolvable(bucket1:Bucket,bucket2:Bucket, goal:Int)->Bool {
		//MARK: CHECK FOR SOLUITONS
		let hasGCD = gcd(bucket1.capacity, bucket2Size: bucket2.capacity)
		print("CHECK FOR SOLVABLE")
		print(" bucket1 - ",bucket1.capacity)
		print(" bucket2 - ",bucket2.capacity)
		print(" goal    - ",goal)
		print(" prime   - ",hasGCD," [BUCKET SIZES MUST BE RELATIVELY PRIME (i.e. GCD = 1)]")


		// MARK: TESTS
		print("\nTESTS")
		if (goal > bucket1.capacity && goal > bucket2.capacity){
			print("* FAIL * Goal must be smaller than the largest bucket")
			return(false)
		}

		if ((bucket1.capacity == bucket2.capacity) && (goal != bucket2.capacity)){
			print("* FAIL * Buckets must be different sizes")
			return(false)
		}

		if (hasGCD == 1 || bucket1.capacity == goal || bucket2.capacity == goal || bucket1.capacity - bucket2.capacity == abs(goal)){
			return(true)
		}
		return(false)

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


	//MARK: FIND NEXT PATH POINT
	/**
	Calculates the Next Path Point in the solution.
	- Parameter bucket1: Bucket1 Object.
	- Parameter bucket2: Bucket2 Object.
	- Parameter goal: Goal Amount Int.

	- Returns:  Bool:
	*/
	func findTheNextPathPoint(var startingBucket: Bucket, var bucket2: Bucket, goal:Int) -> Bool {
		///		completeSwitch = false


		//TODO: if solvable do until solved flag is set
		var solved = false
		while solved == false {
			if(startingBucket.currentAmount == goal || bucket2.currentAmount == goal){
				print("COMPLETE 4 UNITS in B...")
				completeSwitch = true
				return (completeSwitch)!
			}

			//MARK:CASE HERE

			if(solved == false){

				//TOP
				if(bucket1.currentAmount == 0 && (solved == false)){
					// (LARGE FIRST) TRANSFER (LARGE > SMALL)
					transferBucketL2S(bucket2, bucketTo: bucket1)
					//bucket1 = self.fillBucket(bucket1)

					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:" TRANSFER A L2S")}

				//RIGHT
				if(bucket2.currentAmount == bucket2.capacity  && (solved == false)){
					// (LARGE FIRST) TRANSFER (SMALL > LARGE)
					transferBucketL2S(bucket2, bucketTo: bucket1)
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:" TRANSFER B L2S")}

				//LEFT
				if(bucket1.currentAmount > 0 && bucket1.currentAmount < bucket1.capacity && (solved == false)){
					// (LARGE FIRST) ALWAYS FILL
					bucket2 = self.fillBucket(bucket2)
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:" FILL ")}

				//BOTTOM

				if(( bucket1.currentAmount == bucket1.capacity && (solved == false))){
					bucket1 = self.emptyBucket(bucket1)
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:" EMPTY")}


			}
		}
		return (true)
	}

	func getScore(bucket1:Bucket, bucket2:Bucket, goal:Int)-> Bool{

		if(bucket1.currentAmount == goal || bucket2.currentAmount == goal)
		{return (true) }
		else {return (false)}
	}

	//MARK: LOGS
	func logStatus (bucket1:Bucket, bucket2:Bucket, status:String){
		stepNum = stepNum + 1
		print("ACTION   - STEP ",stepNum, "\tSTARTING BUCKET ", "\t[",status, "]")
		logBucketStatus(bucket1)
		logBucketStatus(bucket2)
		print("\n")

		//MARK :ADD STATUS DATA TO TABLE
		let scoreMessage 	= String(bucket1.currentAmount)+"\t|\t"+String(bucket2.currentAmount)
		let stepMessage 	= "\t"+String(stepNum)
		let statusMessage 	= " - "+status
		let lineToAdd = scoreMessage+stepMessage+statusMessage
		actionItems.append(ActionItem(text: lineToAdd))
		tbl_SolutionTable.reloadData()
	}
	func logBucketStatus(bucket:Bucket){
		print(bucket.lastAction, "-",bucket.text,"      - Capacity ", bucket.capacity, "\tCurrent Amount ",bucket.currentAmount, "\tAvailable Capacity ", bucket.availableCapacity)
		bucket.lastAction = "NONE    "
	}





	// MARK: - Actions

	// MARK: o Fill Bucket
	func fillBucket(bucket : Bucket) -> Bucket {
		bucket.currentAmount = bucket.capacity
		bucket.availableCapacity = 0
		let lastAction = "FILLED  "
		bucket.lastAction = lastAction
		//logBucketStatus(bucket)
		return bucket
	}


	// MARK: o Empty Bucket
	func emptyBucket(bucket : Bucket) -> Bucket {
		bucket.currentAmount = 0
		bucket.availableCapacity = bucket.capacity
		let lastAction = "EMPTIED"
		bucket.lastAction = lastAction
		return bucket	}

	// MARK: o Transfer From Bucket1 To Bucket2
	//	func transferBucket(bucketFrom : Bucket, bucketTo : Bucket ){
	//		print("BUCKET XFER (FROM) - Capacity ", bucketFrom.capacity, "\tCurrent Amount ",bucketFrom.currentAmount, "\tAvailable Capacity ", bucketFrom.availableCapacity)
	//		print("BUCKET XFER ( TO ) - Capacity ", bucketTo.capacity, "\tCurrent Amount ",bucketTo.currentAmount, "\tAvailable Capacity ", bucketTo.availableCapacity)
	//		if(bucketFrom.currentAmount < bucketTo.availableCapacity) {
	//
	//			let amountToTransfer    		= bucketFrom.currentAmount
	//			bucketFrom.currentAmount 		= bucketFrom.currentAmount     - amountToTransfer
	//			bucketFrom.availableCapacity 	= bucketFrom.capacity 		   - bucketFrom.currentAmount
	//			bucketTo.currentAmount   		= bucketTo.currentAmount       + amountToTransfer
	//			bucketTo.availableCapacity   	= bucketTo.capacity            - bucketTo.currentAmount
	//
	//
	//		}
	//		else {
	//			let amountToTransfer    		= bucketFrom.currentAmount     - (bucketFrom.currentAmount - bucketTo.availableCapacity)
	//			bucketFrom.currentAmount 		= bucketFrom.currentAmount     - amountToTransfer
	//			bucketFrom.availableCapacity 	= bucketFrom.capacity 		   - bucketFrom.currentAmount
	//			bucketTo.currentAmount   		= bucketTo.currentAmount       + amountToTransfer
	//			bucketTo.availableCapacity   	= bucketTo.capacity            - bucketTo.currentAmount
	//
	//
	//		}
	//		print("\nBUCKET XFER (FROM) - Capacity ", bucketFrom.capacity, "\tCurrent Amount ",bucketFrom.currentAmount, "\tAvailable Capacity ", bucketFrom.availableCapacity)
	//		print("BUCKET XFER ( TO ) - Capacity ", bucketTo.capacity, "\tCurrent Amount ",bucketTo.currentAmount, "\tAvailable Capacity ", bucketTo.availableCapacity)
	//
	//	}

	// MARK: o Transfer
	func transferBucketL2S(bucketFrom : Bucket, bucketTo : Bucket ){
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

	//MARK: * ROTATION
	override func shouldAutorotate() -> Bool {
		return true
	}

	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
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
			cell.textLabel?.text = item.text
			cell.detailTextLabel?.text = "You've got to diffuse a bomb by placing exactly 4 gallons of water on a sensor. The problem is, you only have a 5 gallon (18.9 L) jug and a 3 gallon jug on hand! This classic riddle, made famous in Die Hard 3, may seem impossible without a measuring cup, but it is actually remarkably simple. Click here to watch the clip from the movie if you need to refresh your memory. For the solution, click here to skip to the answer. If you want guidance and hints to solving it on your own, scroll down."
			return cell
	}
	
	
	
}

