//
//  MoreProjectDetailsVC.swift
//  CCLions
//
//  Created by 李冬 on 6/3/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import Eureka

class MoreProjectDetailsVC: UIViewController {

	var moreProjectDetailsView: MoreProjectDetailsView?
	var project: Project?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		initView()
	}

	func initView() -> Void {
		self.initWeight()
		self.initNoti()
		moreProjectDetailsView = MoreProjectDetailsView(frame: self.view.frame)
		moreProjectDetailsView?.delegate = self
        self.view.addSubview(moreProjectDetailsView!)
		moreProjectDetailsView?.setParas(self.project!)

		// 获取捐款记录个数
		MoreProjectDetailsModel.shareInstance().getProjectDonationRecordAmount((self.project?.id)!)
		// 获取提款记录个数
		MoreProjectDetailsModel.shareInstance().getProjectWithdrawRecordAmount((self.project?.id)!)
		// 获取评论记录个数
		MoreProjectDetailsModel.shareInstance().getProjectCommentRcordAmount((self.project?.id)!)
	}

	/**
	 初始化model通知回调
	 */
	func initNoti() -> Void {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MoreProjectDetailsVC.getDonationRecordAmountNotiCallBack(_:)), name: GET_MORE_PROJECT_DONATION_RECORD_AMOUNT_SUCCESS, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MoreProjectDetailsVC.getProjectWithdrawAmountNotiCallBack(_:)), name: GET_MORE_PROJECT_WITHDRAW_RECORD_AMOUNT_SUCCESS, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MoreProjectDetailsVC.getProjectCommentAmountNotiCallBack(_:)), name: GET_MORE_PROJECT_COMMENT_RECORD_AMOUNT_SUCCESS, object: nil)
	}

	func initWeight() -> Void {
		self.title = "更多信息"
	}

	func setParas(project: Project) -> Void {
		self.project = project
	}

	// MARK Noti通知回调
	func getDonationRecordAmountNotiCallBack(noti: NSNotification) -> Void {
		let amount = (noti.object as! NSDictionary).objectForKey(RECORD_AMOUNT) as! String
		moreProjectDetailsView?.setDonationRecordAmount(amount)
	}

	func getProjectWithdrawAmountNotiCallBack(noti: NSNotification) -> Void {
		let amount = (noti.object as! NSDictionary).objectForKey(RECORD_AMOUNT) as! String
		moreProjectDetailsView?.setWithdrawRecordAmount(amount)
	}

	func getProjectCommentAmountNotiCallBack(noti: NSNotification) -> Void {
		let amount = (noti.object as! NSDictionary).objectForKey(RECORD_AMOUNT) as! String
		moreProjectDetailsView?.setCommentRecordAmount(amount)
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

extension MoreProjectDetailsVC: MoreProjectDetailsViewDelegate {
    func donationRecordSelected(project_id: Int) {
        let projectDonationRecordVC = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectDonationRecordVC") as! ProjectDonationRecordVC
        projectDonationRecordVC.project_id = project_id
        projectDonationRecordVC.title = "捐款记录"
        self.navigationController?.pushViewController(projectDonationRecordVC, animated: true)
    }
    
    func withdrawRecordSelected(project_id: Int) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectWithdrawRecordVC") as! ProjectWithdrawRecordVC
        vc.project_id = project_id
        vc.title = "提款记录"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func commentRecordSelected(project_id: Int) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectCommentVC") as! ProjectCommentVC
        vc.title = "评论"
        vc.project_id = project_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
