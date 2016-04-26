//
//  EditTextFieldViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/22.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

typealias sendValueClosure = (string: String, row: Int) -> Void

class EditTextFieldViewController: UITableViewController {
	@IBOutlet var textField: UITextField!
	var contentString: String!
	var myClosure: sendValueClosure!
	var row: Int!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.textField.text = contentString
		self.textField.becomeFirstResponder()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func save(sender: AnyObject) {
		if (myClosure != nil) {
			print("毁掉了")
			myClosure(string: self.textField.text!, row: self.row)
			self.navigationController?.popViewControllerAnimated(true)
		}
	}

	func setClosure(closure: sendValueClosure) -> Void {
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
