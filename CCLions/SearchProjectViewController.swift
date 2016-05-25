//
//  SearchProjectViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/5/1.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyDrop
import SwiftyJSON

class SearchProjectViewController: UIViewController {
	var dataArray: [Project]!

	@IBOutlet var mTableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/**
	 点赞接口

	 - parameter id: 活动id
	 */
	func requestFav(sender: UIButton) -> Void {
		let paras = [
			"user_id": "\(Util.getLoginedUser()!.id)",
			"project_id": "\(sender.tag)"
		]

		print(paras)

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ADD_FAV.rawValue, parameters: paras)
			.responseJSON { (response) in
				if let value = response.result.value {
					print(value)
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 {
						dispatch_async(dispatch_get_main_queue(), {
							// 点赞成功
							let cell = self.mTableView.cellForRowAtIndexPath(NSIndexPath(forRow: (self.getRowForTag(sender.tag)), inSection: 0)) as! ActivityShowTableViewCell
							cell.favLabel.text = "\(Int(cell.favLabel.text!)! + 1)"
						})
					} else {
						let type = json["type"].intValue
						if type == 102 { // 已经点过赞了
							Drop.down(Tips.ADD_FAV_AGAIN, state: DropState.Info)
						} else {
							Drop.down(Tips.ADD_FAV_FAIL, state: DropState.Error)
						}
					}
				} else {
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}
		}
	}

	func getRowForTag(tag: Int) -> Int {
		var row = 0
		for item in self.dataArray {
			if item.id == tag {
				return row
			}
			row += 1
		}

		return row
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
//		cell.favBtn.tag = project.id
//		cell.favBtn.addTarget(self, action: #selector(SearchProjectViewController.requestFav(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
