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

	@IBOutlet var mTableView: UITableView!
	var searchView: SearhView!

	let reuseIdentifier = "ActivityShowTableViewCellReuse"

	// model
	var mainModel: MainVCModel!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		self.initView()
		self.initNotification()
		self.mainModel = MainVCModel.shareInstance()

		// 加入下拉刷新和上拉加载
		mTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(MainViewController.refreshAction))
		mTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(MainViewController.loadMoreAction))

		// 初始在下拉刷新状态
		mTableView.mj_header.state = MJRefreshState.Refreshing

		/**
		 每次进入的时候，首先更新用户的资料
		 */
		updateLoginedUserInfo()
	}

	/**
	 初始化界面
	 */
	func initView() -> Void {
		self.initSearchView()
	}

	/**
	 初始化model通知
	 */
	func initNotification() -> Void {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.refreshDataSuccessNoti(_:)), name: REFRESH_DATA_SUCCESS, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.refreshDataFinishNoti(_:)), name: REFRESH_DATA_FINISH, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.loadMoreDataSuccessNoti(_:)), name: LOAD_MORE_DATA_SUCCESS, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.loadMoreDataFinishNoti(_:)), name: LOAD_MORE_DATA_FINISH, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.searchFinishNoti(_:)), name: GO_TO_SEARCH_PROJECT, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.addFavSuccessNoti(_:)), name: ADD_FAV_SUCCESS, object: nil)
	}

	// Mark Notification
	/**
	 刷新数据成功通知

	 - parameter noti: 通知
	 */
	func refreshDataSuccessNoti(noti: NSNotification) -> Void {
		mTableView.mj_header.state = MJRefreshState.Idle
		mTableView.reloadData()
	}

	/**
	 刷新数据（失败）完成

	 - parameter noti: 通知
	 */
	func refreshDataFinishNoti(noti: NSNotification) -> Void {
		mTableView.mj_header.state = MJRefreshState.Idle
	}

	/**
	 加载更多的数据成功

	 - parameter noti: 通知
	 */
	func loadMoreDataSuccessNoti(noti: NSNotification) -> Void {
		mTableView.mj_footer.state = MJRefreshState.Idle
		mTableView.reloadData()
	}

	/**
	 加载更多数据结束

	 - parameter noti: 通知
	 */
	func loadMoreDataFinishNoti(noti: NSNotification) -> Void {
		mTableView.mj_footer.state = MJRefreshState.Idle
	}

	/**
	 搜索结束通知

	 - parameter noti: 通知
	 */
	func searchFinishNoti(noti: NSNotification) -> Void {
		goToSearchProjectVC()
	}

	/**
	 点赞成功通知

	 - parameter noti: 通知
	 */
	func addFavSuccessNoti(noti: NSNotification) -> Void {

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

	func refreshAction() -> Void {
		self.mainModel.headerRefresh()
	}

	func loadMoreAction() -> Void {
		self.mainModel.footerLoadMore()
	}

	func searchBackClicked() -> Void {
		self.searchView.removeFromSuperview()
		self.view.alpha = 1
	}

	func searchTextFieldEndAction() -> Void {
		self.mainModel.requestSearchWithText(self.searchView.searchTextField.text!)
	}

	/**
	 进入搜索结果展示界面
	 */
	func goToSearchProjectVC() -> Void {
		let searchProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchProjectViewController") as! SearchProjectViewController
		searchProjectViewController.dataArray = mainModel.searchResult
		searchProjectViewController.title = self.searchView.searchTextField.text
		self.searchBackClicked()
		self.navigationController?.pushViewController(searchProjectViewController, animated: true)
	}

	/**
	 点赞接口

	 - parameter id: 活动id
	 */
	func requestFav(sender: UIButton) -> Void {
		self.mainModel.requestFav(Util.getLoginedUser()!.id, project_id: sender.tag)
	}

	func favViewTaped(tap: UITapGestureRecognizer) -> Void {
		let tag = tap.view?.tag
		if !Util.hasUserLogined() {
			Drop.down(Tips.USER_NOT_LOGINED, state: DropState.Warning)
			return
		}
		mainModel.requestFav((Util.getLoginedUser()?.id)!, project_id: mainModel.dataArray[tag!].id)
	}

	/**
	 如果当前有用户登录，那么先请求服务器更新用户的信息
	 */
	func updateLoginedUserInfo() -> Void {
		self.mainModel.updateLoginedUserInfo()
	}
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.mainModel.dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! ActivityShowTableViewCell
		let project = self.mainModel.dataArray[indexPath.row]
		cell.selectionStyle = UITableViewCellSelectionStyle.None
		cell.setParas(project)
		cell.favView.tag = indexPath.row
		cell.favView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainViewController.favViewTaped(_:))))
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.searchBackClicked()
		let projectDetailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectDetailsViewController") as! ProjectDetailsViewController
		projectDetailsViewController.project = self.mainModel.dataArray[indexPath.row]
		self.navigationController?.pushViewController(projectDetailsViewController, animated: true)
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 280
	}
}
