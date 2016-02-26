//
//  ViewController.swift
//  FloTest
//
//  Created by dev on 26/02/2016.
//  Copyright © 2016 dev. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	private var completeSwitch : Bool? = nil
	private var startingBucketSize : String! = "Large"
	private var stepNum : Int = 0
	private var solvable : Bool! = false
	private var goal : Int = 0


	// MARK: - Setup
	// MARK: o Display Solution
	@IBOutlet weak var tbl_SolutionTable: UITableView!
	var actionItems = [ActionItem]()

	// MARK: o New Game
	@IBOutlet weak var btn_StartGame: UIButton!

	// MARK: o Get Input
	// MARK: > Bucket 1 Size
	@IBOutlet weak var txt_Bucket1Size: UITextField!
	// MARK: > Bucket 2 Size
	@IBOutlet weak var txt_Bucket2Size: UITextField!

	// MARK: > Target Amount
	@IBOutlet weak var txt_TargetAmount: UITextField!
	// MARK: > Manual or Automatic


	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		tbl_SolutionTable.dataSource = self
		tbl_SolutionTable.delegate = self
		tbl_SolutionTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")



		//MARK:CONVERT INPUTS TO VALUES
		txt_Bucket1Size.text = "5"
		txt_Bucket2Size.text = "3"

		//

	}

	@IBAction func solveNow(sender: AnyObject) {
		solveIt(self)
	}
	@IBAction func solveIt(sender: AnyObject) {


		//MARK:INIT TABLEVIEW
		if actionItems.count > 0 {
			return
		}
		

		let a:Int! = Int(txt_Bucket1Size.text!)
		let b:Int! = Int(txt_Bucket2Size.text!)

		//MARK: INIT BUCKETS FROM INPUT
		var bucket1 = (Bucket.init(text: "Small", capacity:a))
		var bucket2 = (Bucket.init(text: "Large", capacity:b))
		goal    = 4

		//MARK: CHECK IF SOLVABLE
		solvable = verifySolvable(bucket1,bucket2:bucket2,goal:goal)
		print("SOLVABLE ",solvable,"\n\nSOLUTION STEPS\n")



		if((solvable) == true){

			//MARK: SET THE STARTING BUCKET
			startingBucketSize = "Large"
			logStatus (bucket1, bucket2:bucket2, status: "INIT")


			print("PATH 1")
			
			// MARK: BEGIN BY FILLING A BUCKET 1
			bucket1 = self.fillBucket(bucket1)
			logStatus (bucket2, bucket2:bucket1, status:"FILL")

			// MARK: FIND THE PATH TO SOLUITON 1
			self.findTheNextPathPoint(bucket2, bucket2: bucket1, goal:goal)
			print("SOLUTION 1 FOUND IN ", stepNum, " STEPS\n")

			print("PATH 2")

			resetBuckets(bucket1, bucket2:bucket2)

			// MARK: BEGIN BY FILLING A BUCKET 2
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
}


	func verifySolvable(bucket1:Bucket,bucket2:Bucket, goal:Int)->Bool {
		//MARK: CHECK FOR SOLUITONS
		var hasGCD = gcd(bucket1.capacity, bucket2Size: bucket2.capacity)
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
		if (hasGCD == 1 || bucket1.capacity == goal || bucket2.capacity == goal || bucket1.capacity - bucket2.capacity == abs(goal)){
			return(true)
		}
		return(false)

	}
	// GCD of two numbers:
	func gcd(var bucket1Size : Int, var bucket2Size : Int) -> Int {
		while bucket2Size != 0 {
			(bucket1Size, bucket2Size) = (bucket2Size, bucket1Size % bucket2Size)
		}
		return abs(bucket1Size)
	}


	//MARK: FIND NEXT PATH POINT
	func findTheNextPathPoint(var bucket1: Bucket, var bucket2: Bucket, goal:Int) -> Bool {
		///		completeSwitch = false


		//TODO: if solvable do until solved flag is set
		var solved = false
		while solved == false {
			if(bucket1.currentAmount == goal || bucket2.currentAmount == goal){
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
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:" TOP ")}

				//RIGHT
				if(bucket2.currentAmount == bucket2.capacity  && (solved == false)){
					// (LARGE FIRST) TRANSFER (SMALL > LARGE)
					transferBucketL2S(bucket2, bucketTo: bucket1)
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:" RIGHT ")}

				//LEFT
				if(bucket1.currentAmount > 0 && bucket1.currentAmount < bucket1.capacity && (solved == false)){
					// (LARGE FIRST) ALWAYS FILL
					bucket2 = self.fillBucket(bucket2)
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:" LEFT  ")}

				//BOTTOM

				if(( bucket1.currentAmount == bucket1.capacity && (solved == false))){
					bucket1 = self.emptyBucket(bucket1)
					solved = getScore(bucket1,bucket2: bucket2,goal:goal)
					logStatus (bucket1, bucket2:bucket2, status:"BOTTOM")}


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
		print("ACTION   - STEP ",stepNum, "\tSTARTING BUCKET ",startingBucketSize, "\t[",status, "]")
		logBucketStatus(bucket1)
		logBucketStatus(bucket2)
   		print("\n")

		//MARK :ADD STATUS DATA TO TABLE
        var scoreMessage 	= String(bucket1.currentAmount)+"\t|\t"+String(bucket2.currentAmount)
		var stepMessage 	= "\t"+String(stepNum)
		var statusMessage 	= " - "+status
		var lineToAdd = scoreMessage+stepMessage+statusMessage
		actionItems.append(ActionItem(text: lineToAdd))
	}
	func logBucketStatus(bucket:Bucket){
		print(bucket.lastAction, "-",bucket.text,"      - Capacity ", bucket.capacity, "\tCurrent Amount ",bucket.currentAmount, "\tAvailable Capacity ", bucket.availableCapacity)
		bucket.lastAction = "NONE    "
	}





	// MARK: - Actions
	// MARK: o Select Bucket
	// MARK: o Select Action

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
	func transferBucket(bucketFrom : Bucket, bucketTo : Bucket ){
		print("BUCKET XFER (FROM) - Capacity ", bucketFrom.capacity, "\tCurrent Amount ",bucketFrom.currentAmount, "\tAvailable Capacity ", bucketFrom.availableCapacity)
		print("BUCKET XFER ( TO ) - Capacity ", bucketTo.capacity, "\tCurrent Amount ",bucketTo.currentAmount, "\tAvailable Capacity ", bucketTo.availableCapacity)
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
		print("\nBUCKET XFER (FROM) - Capacity ", bucketFrom.capacity, "\tCurrent Amount ",bucketFrom.currentAmount, "\tAvailable Capacity ", bucketFrom.availableCapacity)
		print("BUCKET XFER ( TO ) - Capacity ", bucketTo.capacity, "\tCurrent Amount ",bucketTo.currentAmount, "\tAvailable Capacity ", bucketTo.availableCapacity)

	}

	// MARK: o Transfer From Bucket2 To Bucket1
	func transferBucketL2S(bucketFrom : Bucket, bucketTo : Bucket ){
		bucketFrom.lastAction = "XFER OUT"
		bucketTo.lastAction = "XFER IN "

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
		//
		//        logBucketStatus(bucketFrom)
		//		logBucketStatus(bucketTo)
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
				forIndexPath: indexPath) as! UITableViewCell
			let item = actionItems[indexPath.row]
			cell.textLabel?.text = item.text
			return cell
	}
	

	
}

