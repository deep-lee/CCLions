//
//  ProjectDetailsViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/11.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyDrop
import SnapKit

class ProjectDetailsViewController: WPEditorViewController {
	var project: Project!
	var videoPressCache: NSCache = NSCache()
	var mediaAdded: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
	var contentHtml: String?
	// var flowView: FlowView!
	var newFlowView: NewFlowView!
	var loved = false
	var model: ProjectDetailsModel!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.delegate = self
		initNoti()
		self.initView()
		self.initWeight()
		self.updateEditorView()
	}

	func initView() -> Void {
		model = ProjectDetailsModel.shareInstance()
//        flowView = FlowView(frame: CGRectZero)
//        self.view.insertSubview(flowView, aboveSubview: self.editorView)
//        flowView.snp_makeConstraints { (make) in
//            make.left.bottom.right.equalTo(0)
//            make.height.equalTo(180)
//        }
//        flowView.delegate = self

		newFlowView = NewFlowView(frame: CGRectZero)
		self.view.insertSubview(newFlowView, aboveSubview: self.editorView)
		newFlowView.snp_makeConstraints { (make) in
			make.left.bottom.right.equalTo(0)
			make.height.equalTo(80)
		}
		newFlowView.delegate = self

		// 判断当前用户是否点赞了这个项目
		model.checkUserHasLovedProject(self.project.id)
	}

	func initNoti() -> Void {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectDetailsViewController.checkUserHasLovedProjectNotiCallBack(_:)), name: CHECK_USER_HAS_LOVED_PROJECT, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectDetailsViewController.addFavSuccessNotiCallBack(_:)), name: ADD_FAV_SUCCESS, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectDetailsViewController.deleteFavSuccessNotiCallBack(_:)), name: DELETE_FAV_SUCCESS, object: nil)
	}

	/**
	 判断用户是否点赞了项目回调

	 - parameter noti: 回调通知
	 */
	func checkUserHasLovedProjectNotiCallBack(noti: NSNotification) -> Void {
		let object = noti.object as! NSDictionary
		let result = object.objectForKey(CHECK_LOVED_RECULT)?.integerValue
		if result == 0 {
			// 没有点赞
			self.newFlowView.buttonLove.setImage(UIImage(named: "icon-flow-love"), forState: UIControlState.Normal)
			loved = false
		} else if result == 1 {
			// 已经点赞了
			self.newFlowView.buttonLove.setImage(UIImage(named: "icon-flow-loved"), forState: UIControlState.Normal)
			loved = true
		}
	}

	/**
	 点赞成功回调

	 - parameter noti: 回调通知
	 */
	func addFavSuccessNotiCallBack(noti: NSNotification) -> Void {
		self.newFlowView.buttonLove.setImage(UIImage(named: "icon-flow-loved"), forState: UIControlState.Normal)
		loved = true
	}

	/**
	 取消点赞回调

	 - parameter noti: 通知回调
	 */
	func deleteFavSuccessNotiCallBack(noti: NSNotification) -> Void {
		self.newFlowView.buttonLove.setImage(UIImage(named: "icon-flow-love"), forState: UIControlState.Normal)
		loved = false
	}

	func updateEditorView() {
		SVProgressHUD.showWithStatus("正在加载...")
		Alamofire.request(.GET, self.project.details_page)
			.responseData { (response) in
				if let data = response.result.value {
					self.contentHtml = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
					self.updateHtml()
				} else {
					Drop.down(Tips.LOADING_FAIL, state: DropState.Error)
				}

				SVProgressHUD.dismiss()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if self.editorView.contentField != nil {
			self.editorView.titleField.disableEditing()
			self.editorView.contentField.disableEditing()
		}
	}

	override func viewWillAppear(animated: Bool) {
		self.navigationController?.navigationBar.hidden = true
	}

	func updateHtml() -> Void {
		if self.editorView.contentField != nil && self.contentHtml != nil {
			self.editorView.titleField.disableEditing()
			self.editorView.contentField.disableEditing()
			self.editorView.contentField.setHtml(self.contentHtml!)
			self.editorView.titleField.setText(self.project.title)
		}
	}

	/**
	 初始化导航栏
	 */
	func initWeight() -> Void {
		self.title = "活动详情"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "更多信息", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ProjectDetailsViewController.moreDetailsAction))
	}

	/**
	 进入到更多详情界面
	 */
	func moreDetailsAction() -> Void {
		let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MoreProjectDetailsVC") as! MoreProjectDetailsVC
		vc.setParas(self.project)
		self.navigationController?.pushViewController(vc, animated: true)
	}
}

extension ProjectDetailsViewController: WPEditorViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	// 开始编辑
	func editorDidBeginEditing(editorController: WPEditorViewController!) {
		print("Editor did begin editing.")
		self.updateHtml()
	}

	// 结束编辑
	func editorDidEndEditing(editorController: WPEditorViewController!) {
		print("Editor did end editing.")
	}

	// 加载HTML结束
	func editorDidFinishLoadingDOM(editorController: WPEditorViewController!) {
		// let path = NSBundle.mainBundle().pathForResource("content", ofType: "html")
		// let htmlParam = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
		// self.titleText = "I'm editing a post!"
	}

	func editorShouldDisplaySourceView(editorController: WPEditorViewController!) -> Bool {
		self.editorView.pauseAllVideos()
		return true
	}

	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
		self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
			// let assetURL = info[UIImagePickerControllerReferenceURL] as! NSURL
			// print(assetURL)
			// self.addAssetToContent(assetURL)
		})
	}

	// 添加图片
	func editorDidPressMedia(editorController: WPEditorViewController!) {
		// self.showPhotoPicker()
	}

	func editorTitleDidChange(editorController: WPEditorViewController!) {
	}

	func editorTextDidChange(editorController: WPEditorViewController!) {
	}

	func editorViewController(editorViewController: WPEditorViewController!, fieldCreated field: WPEditorField!) {
	}

	// 点击图片
	func editorViewController(editorViewController: WPEditorViewController!, imageTapped imageId: String!, url: NSURL!, imageMeta: WPImageMeta) {
	}

	// 点击视频
	func editorViewController(editorViewController: WPEditorViewController!, videoTapped videoID: String!, url: NSURL!) {
	}

	func editorViewController(editorViewController: WPEditorViewController!, imageReplaced imageId: String!) {
		self.mediaAdded.removeValueForKey(imageId)
	}

	func editorViewController(editorViewController: WPEditorViewController!, videoReplaced videoID: String!) {
		self.mediaAdded.removeValueForKey(videoID)
	}

	func editorViewController(editorViewController: WPEditorViewController!, videoPressInfoRequest videoID: String!) {
		let videoPressInfo = self.videoPressCache.objectForKey(videoID) as! NSDictionary
		let videoURL = videoPressInfo["source"] as! String?
		let posterURL = videoPressInfo["poster"] as! String?

		if (videoURL != nil) {
			self.editorView.setVideoPress(videoID, source: videoURL, poster: posterURL)
		}
	}

	func editorViewController(editorViewController: WPEditorViewController!, mediaRemoved mediaID: String!) {
		let progress = self.mediaAdded[mediaID] as! NSProgress
		progress.cancel()
	}
}

extension ProjectDetailsViewController: NewFlowViewDelegate {
	func buttonBackClicked() {
		self.navigationController?.popViewControllerAnimated(true)
	}

	func buttonLoveClicked() {
		if loved {
			// 如果已经点赞了
			model.deleteFav(self.project.id)
		} else {
			// 如果没有点赞
			model.addFav(self.project.id)
		}
	}

	func buttonCommentClicked() {
		let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectCommentVC") as! ProjectCommentVC
		vc.project_id = self.project.id
		vc.project = project
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func buttonShareClicked() {

	}
}

//extension ProjectDetailsViewController: FlowViewDelegate {
//    func buttonBackClicked() {
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//
//    func buttonLoveClicked() {
//        if loved {
//            // 如果已经点赞了
//            model.deleteFav(self.project.id)
//        } else {
//            // 如果没有点赞
//            model.addFav(self.project.id)
//        }
//    }
//
//    func buttonSupportClicked() {
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DonateVC") as! DonateVC
//        vc.project = project
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func buttonShareClicked() {
//
//    }
//
//    func buttonMoreClicked() {
//
//    }
//
//    func buttonCommentClicked() {
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectCommentVC") as! ProjectCommentVC
//        vc.project_id = self.project.id
//        vc.project = project
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func buttonDonationRecordClicked() {
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectDonationRecordVC") as! ProjectDonationRecordVC
//        vc.project_id = project.id
//        vc.project = project
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func buttonWithdrawRecordClicked() {
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectWithdrawRecordVC") as! ProjectWithdrawRecordVC
//        vc.project_id = project.id
//        vc.project = project
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}

