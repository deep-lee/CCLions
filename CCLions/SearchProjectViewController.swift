//
//  SearchProjectViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/5/1.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class SearchProjectViewController: UIViewController {
	var dataArray: [Project]!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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

extension SearchProjectViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("SearchShowCell") as! ActivityShowTableViewCell
		let project = self.dataArray[indexPath.row]
		cell.showIamgeView.sd_setImageWithURL(NSURL(string: project.cover_image))
		cell.activityTimeLabel.text = project.time
		cell.activityLauncherLabel.text = project.name
		cell.favLabel.text = "\(project.favorite)"

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		let projectDetailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectDetailsViewController") as! ProjectDetailsViewController
		projectDetailsViewController.project = self.dataArray[indexPath.row]
		self.navigationController?.pushViewController(projectDetailsViewController, animated: true)
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 310
	}
}
