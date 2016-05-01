//
//  SearchResultViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/5/1.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {
	var dataArray: [Company]!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func goToCompanyShowVC(row: Int) -> Void {
		let companyShowViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CompanyShowViewController") as! CompanyShowViewController
		companyShowViewController.company = self.dataArray[row]
		companyShowViewController.title = "公司详情"
		self.navigationController?.pushViewController(companyShowViewController, animated: true)
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

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultTableViewCell", forIndexPath: indexPath) as! SearchResultTableViewCell
		let company = self.dataArray[indexPath.row]
		cell.compamyLogoImageView.sd_setImageWithURL(NSURL(string: company.company_logo))
		cell.companyNameLabel.text = company.company_name
		cell.companyBusinessLabel.text = company.business_scope
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.goToCompanyShowVC(indexPath.row)
	}
}
