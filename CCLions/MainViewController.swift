//
//  MainViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/2/13.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop
import SwiftyJSON
import Alamofire
import SDWebImage

class MainViewController: UIViewController {
	@IBOutlet weak var activityShowTableView: UITableView!
	var dataArray: [Project]!
	// 已展示的最后一条数据的id
	var lastId = Int.max

	var searchView: SearhView!

	var searchResult: [Project]!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		self.dataArray = [Project]()
		self.searchResult = [Project]()
		// 加入下拉刷新和上拉加载
		activityShowTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(MainViewController.headerRefresh))
		activityShowTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(MainViewController.footerLoadMore))

		// 初始在下拉刷新状态
		activityShowTableView.mj_header.state = MJRefreshState.Refreshing

		initSearchView()
        
        updateLoginedUserInfo()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.setNavigationBarItem()
	}

	@IBAction func leftMenu(sender: AnyObject) {
		slideMenuController()?.toggleLeft()
	}

	@IBAction func searchAction(sender: AnyObject) {
		self.navigationController?.view.addSubview(self.searchView)
		self.searchView.searchTextField.becomeFirstResponder()
		self.view.alpha = 0.5
	}

	func initSearchView() -> Void {
		self.searchView = SearhView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
		searchView.buttonCallBack = searchBackClicked
		searchView.searchTextFieldEndCallBack = searchTextFieldEndAction
	}

	func searchBackClicked() -> Void {
		self.searchView.removeFromSuperview()
		self.view.alpha = 1
	}

	func searchTextFieldEndAction() -> Void {
		self.requestSearchWithText(self.searchView.searchTextField.text!)
	}

	func goToSearchProjectVC() -> Void {
		let searchProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchProjectViewController") as! SearchProjectViewController
		searchProjectViewController.dataArray = self.searchResult
		searchProjectViewController.title = self.searchView.searchTextField.text
		self.searchBackClicked()
		self.navigationController?.pushViewController(searchProjectViewController, animated: true)
	}

	func requestSearchWithText(text: String) -> Void {
		SVProgressHUD.show()
		let paras = [
			"search_text": text
		]

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_SEARCH_PROJECT.rawValue, parameters: paras)
			.responseJSON { (response) in
				print(response)
				if let value = response.result.value {
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 { // 请求成功
						self.searchResult.removeAll()
						let data = json["data"].arrayValue
						if data.count != 0 {
							for item in data {
								let project = Project(id: item["id"].intValue, title: item["title"].stringValue, time: item["time"].stringValue, launcher_id: item["launcher_id"].intValue, favorite: item["favorite"].intValue, cover_image: item["cover_image"].stringValue, details_page: item["details_page"].stringValue, create_time: item["create_time"].stringValue, name: item["name"].stringValue)

								self.searchResult.append(project)
							}

							if self.searchResult.count != 0 {
								self.goToSearchProjectVC()
							} else {
								Drop.down(Tips.SEARCH_NO_RESULT, state: DropState.Warning)
							}
						} else {
							Drop.down(Tips.SEARCH_NO_RESULT, state: DropState.Info)
						}
					} else {
						Drop.down(Tips.SEARCH_PROJECT_FAIL, state: DropState.Error)
					}
				} else {
					// 显示错误信息
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}

				SVProgressHUD.dismiss()
		}
	}

	/**
	 下拉刷新
	 */
	func headerRefresh() -> Void {
		self.lastId = Int.max
		print("正在下拉刷新")
		let paras = [
			"lastId": self.lastId
		]

		print(paras)

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_PROJECT_PAGE.rawValue, parameters: paras)
			.responseJSON { (response) in
				// 返回不为空
				if let value = response.result.value {
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue

					// print(json)
					if code == 200 { // 请求成功
						let data = json["data"].arrayValue
						if data.count != 0 {
							self.dataArray.removeAll()
							for item in data {
								let project = Project(id: item["id"].intValue, title: item["title"].stringValue, time: item["time"].stringValue, launcher_id: item["launcher_id"].intValue, favorite: item["favorite"].intValue, cover_image: item["cover_image"].stringValue, details_page: item["details_page"].stringValue, create_time: item["create_time"].stringValue, name: item["name"].stringValue)

								self.dataArray.append(project)
							}

							// 重新加载TableView数据
							self.activityShowTableView.reloadData()
							self.lastId = (self.dataArray.last?.id)!
						}
					}
				} else {
					// 显示错误信息
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}

				self.activityShowTableView.mj_header.state = MJRefreshState.Idle
		}
	}

	func footerLoadMore() -> Void {
		print("正在加载更多")
		let paras = [
			"lastId": self.lastId
		]

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_PROJECT_PAGE.rawValue, parameters: paras)
			.responseJSON { (response) in
				// 返回不为空
				if let value = response.result.value {
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue

					print(json)
					if code == 200 { // 请求成功
						let data = json["data"].arrayValue
						if data.count != 0 {
							for item in data {
								let project = Project(id: item["id"].intValue, title: item["title"].stringValue, time: item["time"].stringValue, launcher_id: item["launcher_id"].intValue, favorite: item["favorite"].intValue, cover_image: item["cover_image"].stringValue, details_page: item["details_page"].stringValue, create_time: item["create_time"].stringValue, name: item["name"].stringValue)

								self.dataArray.append(project)
								let path = NSIndexPath(forRow: self.dataArray.count, inSection: 0)
								self.activityShowTableView.insertRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Right)
							}

							// 重新加载TableView数据
							self.lastId = (self.dataArray.last?.id)!
						}
					}
				} else {
					// 显示错误信息
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}

				self.activityShowTableView.mj_footer.state = MJRefreshState.Idle
		}
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
							let cell = self.activityShowTableView.cellForRowAtIndexPath(NSIndexPath(forRow: (self.getRowForTag(sender.tag)), inSection: 0)) as! ActivityShowTableViewCell
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
    
    /**
     如果当前有用户登录，那么先请求服务器更新用户的信息
     */
    func updateLoginedUserInfo() -> Void {
        if Util.hasUserLogined() {
            let paras = [
                "userId": "\(Util.getLoginedUser()?.id)"
            ]
            
            Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_USER_INFO_WITH_ID.rawValue, parameters: paras)
            .responseJSON(completionHandler: { (response) in
                // 返回不为空
                if let value = response.result.value {
                    // 解析json
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 200 { // 登录成功
                        // 获取登录的用户信息
                        let data = json["data"]
                        let user = User(id: data["id"].intValue, username: data["username"].stringValue, password: data["password"].stringValue, header: data["header"].stringValue, name: data["name"].stringValue, sex: data["sex"].intValue, address: data["address"].stringValue, contact: data["contact"].stringValue, service_team: data["service_team"].stringValue, update_time: data["update_time"].stringValue)
                        
                        // 存储登录用户的信息
                        Util.updateUser(user)
                    }
                }
            })
        }
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

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("MainShowCell") as! ActivityShowTableViewCell
		let project = self.dataArray[indexPath.row]
		cell.showIamgeView.sd_setImageWithURL(NSURL(string: project.cover_image))
		cell.activityTimeLabel.text = project.time
		cell.activityLauncherLabel.text = project.name
		cell.favLabel.text = "\(project.favorite)"
		cell.favBtn.tag = project.id
		cell.favBtn.addTarget(self, action: #selector(MainViewController.requestFav(_:)), forControlEvents: UIControlEvents.TouchUpInside)

		return cell
	}

	/**
	 给cell添加动画

	 */
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 200,
			50, 0)
		cell.layer.transform = rotationTransform
		UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
			cell.layer.transform = CATransform3DIdentity
			}, completion: nil)
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.searchBackClicked()
		let projectDetailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectDetailsViewController") as! ProjectDetailsViewController
		projectDetailsViewController.project = self.dataArray[indexPath.row]
		self.navigationController?.pushViewController(projectDetailsViewController, animated: true)
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 310
	}
}
