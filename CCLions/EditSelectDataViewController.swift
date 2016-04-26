//
//  EditSelectDataViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/23.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

typealias sendSelectedRowClosure = (row: Int, selectedRow: Int) -> Void

class EditSelectDataViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	var dataArray: [String]!
	var selectedIndex: Int!
	var row: Int!
	var myClosure: sendSelectedRowClosure!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func setClosure(closure: sendSelectedRowClosure) -> Void {
		self.myClosure = closure
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}

extension EditSelectDataViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("EditSelectDataTableViewCell", forIndexPath: indexPath)
		cell.textLabel?.text = self.dataArray[indexPath.row]

		if selectedIndex == indexPath.row {
			cell.accessoryType = UITableViewCellAccessoryType.Checkmark
		} else {
			cell.accessoryType = UITableViewCellAccessoryType.None
		}

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.selectedIndex = indexPath.row
		if (self.myClosure != nil) {
			myClosure(row: self.row, selectedRow: indexPath.row)
            self.navigationController?.popViewControllerAnimated(true)
		}
	}
}
