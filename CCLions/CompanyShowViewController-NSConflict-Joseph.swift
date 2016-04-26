//
//  CompanyShowViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/26.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class CompanyShowViewController: UIViewController {
	@IBOutlet var topScrollView: UIScrollView!
	@IBOutlet var bottomScrollView: UIScrollView!
	var companyNameLabel: UILabel?
	var companyIntroTextView: UITextView?
	var company: Company?
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	func initTopScrollView() -> Void {
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func contact(sender: AnyObject) {
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
