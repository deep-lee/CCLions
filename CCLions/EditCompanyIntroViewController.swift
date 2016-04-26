//
//  EditCompanyIntroViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/21.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class EditCompanyIntroViewController: UIViewController {
	@IBOutlet weak var textView: UITextView!
	var text: String!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.title = "公司简介"
		self.textView.becomeFirstResponder()
		self.textView.text = self.text
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().postNotificationName("COMPANY_INFO_CHANGED", object: nil, userInfo: ["intro": self.textView.text])
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
