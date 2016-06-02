//
//  EditSelfProfileViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/6.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices
import Alamofire
import SwiftyDrop
import SwiftyJSON
import SlideMenuControllerSwift

class EditSelfProfileViewController: UIViewController {
	var dataArray: [(String, String)]!
	var user: User!
	var headerChanged = false
	var selectSex = 0
	// 标记是更新用户资料还是完成用户资料，true表示更新用户资料
	var flag = true

	@IBOutlet weak var headerImageView: UIImageView!
	@IBOutlet weak var tableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		initData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/**
	 初始化数据和界面

	 */
	func initData() {
		self.user = Util.getLoginedUser()
		self.dataArray = [(String, String)]()
		dataArray.append(("真实姓名", user.name))
		dataArray.append(("性别", user.sex == 1 ? "男" : "女"))
		dataArray.append(("地址", user.address))
		dataArray.append(("联系方式", user.contact))

		// 如果不是狮子会会员的话就需要填写所属服务队
		if user.user_type == UserType.CCLionVip.rawValue {
			dataArray.append(("所属服务队", user.service_team))
		}

		self.headerImageView.sd_setImageWithURL(NSURL(string: self.user.header)) { (image, error, cacheType, url) in
			if (image != nil) {
				self.headerImageView.image = image.imageWithCornerRadius(self.headerImageView.bounds.size.width / 2)
			} else {
				self.headerImageView.image = UIImage(named: "icon-default-header")?.imageWithCornerRadius(self.headerImageView.bounds.size.width / 2)
			}
		}

		let tap = UITapGestureRecognizer(target: self, action: #selector(EditSelfProfileViewController.headerImageTaped(_:)))
		self.headerImageView.userInteractionEnabled = true
		self.headerImageView.addGestureRecognizer(tap)

		self.selectSex = user.sex
	}

	/**
	 图片点击事件，选择头像

	 - parameter tap: 手势
	 */
	func headerImageTaped(tap: UITapGestureRecognizer) -> Void {
		print("Taped")
		// 进入图片选择界面
		let actionViewController = UIAlertController(title: "选择照片", message: "照片路径", preferredStyle: UIAlertControllerStyle.ActionSheet)
		let cameraAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default) { (action) in
			if Util.isCameraAvailable() && Util.doesCameraSupportTakingPhotos() {
				let controller = UIImagePickerController()
				controller.sourceType = UIImagePickerControllerSourceType.Camera

				if Util.isFrontCameraAvailable() {
					controller.cameraDevice = UIImagePickerControllerCameraDevice.Front
				}

				var mediaTypes = [String]()
				mediaTypes.append(kUTTypeImage as String)
				controller.mediaTypes = mediaTypes
				controller.delegate = self
				self.presentViewController(controller, animated: true, completion: nil)
			}
		}

		let photoLibrayAction = UIAlertAction(title: "从相册中选取", style: UIAlertActionStyle.Default) { (action) in
			if Util.isPhotoLibraryAvailable() {
				let controller = UIImagePickerController()
				controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary

				var mediaTypes = [String]()
				mediaTypes.append(kUTTypeImage as String)
				controller.mediaTypes = mediaTypes
				controller.delegate = self
				self.presentViewController(controller, animated: true, completion: nil)
			}
		}

		let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)

		actionViewController.addAction(cancelAction)
		actionViewController.addAction(cameraAction)
		actionViewController.addAction(photoLibrayAction)

		self.presentViewController(actionViewController, animated: true, completion: nil)
	}

	/**
	 保存事件

	 - parameter sender: 消息传递者
	 */
	@IBAction func saveAction(sender: AnyObject) {
		SVProgressHUD.showWithStatus("正在保存...")
		// 如果是更新用户资料
		if flag {
			print("更新用户资料")
			// 1. 如果头像改变了，就先上传头像
			if hasCompletedInfo() {
				if headerChanged {
					self.uploadUserHeader()
				} else {
					self.updateUserInfo(user.header)
				}

			} else {
				Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
				SVProgressHUD.dismiss()
			}
		} else { // 如果是完成用户资料
			print("完成用户资料")
			if self.headerChanged && hasCompletedInfo() {
				print("完成用户资料时，上传头像")
				self.uploadUserHeader()
			} else { // 资料填写不完整
				Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
				SVProgressHUD.dismiss()
			}
		}
	}

	/**
	 上传用户头像
	 */
	func uploadUserHeader() -> Void {
		// 首先上传用户的头像
		Alamofire.upload(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_UPLOAD_HEADER_IMAGE.rawValue, data: UIImageJPEGRepresentation(self.headerImageView.image!, 0.5)!)
			.responseJSON(completionHandler: { (response) in
				if let value = response.result.value {

					print(value)
					// 解析JSON
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 { // 上传成功
						let data = json["data"].stringValue
						// 更新资料
						self.updateUserInfo(HttpRequest.HTTP_ADDRESS + data)
					} else { // 上传失败
						Drop.down(Tips.EDIT_SELF_INFO_UPLOAD_HEADER_FAIL, state: DropState.Error)
						SVProgressHUD.dismiss()
					}
				} else { // 返回为空，说明网络连接失败
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
					SVProgressHUD.dismiss()
				}
		})
	}

	/**
	 更新用户资料

	 - parameter headerAddress: 头像地址
	 */
	func updateUserInfo(headerAddress: String) -> Void {
		let paras = [
			"userId": self.user.id,
			"header": headerAddress,
			"name": self.dataArray[0].1,
			"sex": self.selectSex,
			"address": self.dataArray[2].1,
			"contact": self.dataArray[3].1,
			"service_team": self.user.user_type == UserType.NonVip.rawValue ? "" : self.dataArray[4].1
		]

		print(paras)

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_COMPLETE_USER_INFO.rawValue, parameters: paras as? [String: AnyObject])
			.responseJSON { (response) in
				if let value = response.result.value {
					print(value)
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 {
						// 更新成功
						let data = json["data"]
						let user = User(
							id: data["id"].intValue,
							username: data["username"].stringValue,
							password: data["password"].stringValue,
							header: data["header"].stringValue,
							name: data["name"].stringValue,
							sex: data["sex"].intValue,
							address: data["address"].stringValue,
							contact: data["contact"].stringValue,
							user_type: data["user_type"].intValue,
							service_team: data["service_team"].stringValue,
							authentication_status: data["authentication_status"].intValue,
							update_time: data["update_time"].stringValue)

						// 存储登录用户的信息
						Util.updateUser(user)

						Drop.down(Tips.EDIT_SELF_INFO_UPDATE_SUCCESS, state: DropState.Success)

						if self.flag { // 如果是更新用户资料
							self.navigationController?.popViewControllerAnimated(true)
						} else { // 如果是完成用户资料
							// 进入到主界面
							self.goToMainActivity()
						}
					} else {
						Drop.down(Tips.EDIT_SELF_INFO_UPDATE_ERROR, state: DropState.Error)

					}
				} else { // 网络连接出错
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}

				SVProgressHUD.dismiss()
		}
	}

	/**
	 进入到主界面
	 */
	func goToMainActivity() -> Void {
		let leftViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SlideViewController") as! SlideViewController

		let nvc: UINavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("MainNavagationController") as! UINavigationController
		nvc.navigationBar.barTintColor = UIColor(hex: "0395d8")
		leftViewController.mainViewController = nvc

		let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
		slideMenuController.automaticallyAdjustsScrollViewInsets = true
		self.presentViewController(slideMenuController, animated: true, completion: nil)
	}

	/**
	 判断用户基本资料是否填写完成

	 - returns:
	 */
	func hasCompletedInfo() -> Bool {
		for item in self.dataArray {
			if item.0 == "" {
				return false
			}
		}

		if !flag { // 如果当前是完成用户信息
			if !self.headerChanged { // 如果用户的头像没有选择
				return false
			}
		}

		return true
	}

	func goToEditTextFieldVC(row: Int) -> Void {
		let editTextFieldViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditTextFieldViewController") as! EditTextFieldViewController
		editTextFieldViewController.title = self.dataArray[row].0
		editTextFieldViewController.contentString = self.dataArray[row].1
		editTextFieldViewController.row = row
		editTextFieldViewController.setClosure(editFieldCallBack)
		self.navigationController?.pushViewController(editTextFieldViewController, animated: true)
	}

	func editFieldCallBack(string: String, row: Int) -> Void {
		print("接收到了回调")
		print(string + " \(row)")
		self.dataArray[row].1 = string
		self.tableView.reloadData()
	}

	func goToEditSelectDataVC(row: Int) -> Void {
		let editSelectDataViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditSelectDataViewController") as! EditSelectDataViewController
		editSelectDataViewController.title = self.dataArray[row].0
		editSelectDataViewController.dataArray = Util.SEX
		editSelectDataViewController.selectedIndex = self.selectSex
		editSelectDataViewController.row = row
		editSelectDataViewController.setClosure(editSelectDataCallBack)
		self.navigationController?.pushViewController(editSelectDataViewController, animated: true)
	}

	func editSelectDataCallBack(row: Int, selectedRow: Int) -> Void {
		if row == 1 {
			self.selectSex = selectedRow
			self.dataArray[1].1 = Util.SEX[selectedRow]
			self.tableView.reloadData()
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

extension EditSelfProfileViewController: UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("EditSelfProfileCell", forIndexPath: indexPath)

		cell.textLabel?.text = dataArray[indexPath.row].0
		cell.detailTextLabel?.text = dataArray[indexPath.row].1

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		switch indexPath.row {
		case 0, 2, 3, 4:
			self.goToEditTextFieldVC(indexPath.row)
		case 1:
			self.goToEditSelectDataVC(indexPath.row)
		default:
			return
		}
	}

	// pragma mark VPImageCropperDelegate
	func imageCropper(cropperViewController: VPImageCropperViewController!, didFinished editedImage: UIImage!) {
		self.headerImageView.image = editedImage.imageWithCornerRadius(self.headerImageView.bounds.size.width / 2)
		self.headerChanged = true
		cropperViewController.dismissViewControllerAnimated(true, completion: nil)
	}

	func imageCropperDidCancel(cropperViewController: VPImageCropperViewController!) {
		cropperViewController.dismissViewControllerAnimated(true, completion: nil)
	}

	// pragma mark - UIImagePickerControllerDelegate
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
		picker.dismissViewControllerAnimated(true) {
			var portraitImg = info[UIImagePickerControllerOriginalImage] as! UIImage
			portraitImg = Util.imageByScalingToMaxSize(portraitImg)

			let imgCropperVC = VPImageCropperViewController(image: portraitImg, cropFrame: CGRectMake(0, 100.0, self.view.frame.size.width, self.view.frame.size.width), limitScaleRatio: 3)
			imgCropperVC.delegate = self
			self.presentViewController(imgCropperVC, animated: true, completion: nil)
		}
	}

	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		picker.dismissViewControllerAnimated(true, completion: nil)
	}
}
