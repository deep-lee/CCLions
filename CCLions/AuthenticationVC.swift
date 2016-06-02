//
//  AuthenticationVC.swift
//  CCLions
//
//  Created by 李冬 on 6/1/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices
import SwiftyDrop

class AuthenticationVC: UIViewController {

	@IBOutlet var labelSuccessTips: UILabel!
	var dataArray = ["身份证正面照片", "身份证反面照片"]
	var curIndexPath: NSIndexPath!
	var photoSelectedArray = [false, false]
	@IBOutlet var mTableView: UITableView!
	var user: User!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.initWeight()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func initWeight() -> Void {
		self.user = Util.getLoginedUser()
		if self.user.authentication_status == UserAuthenticationStatus.SuccessAuthentication.rawValue {
			// 认证通过
			self.mTableView.hidden = true
			self.labelSuccessTips.hidden = false;
		} else if self.user.authentication_status == UserAuthenticationStatus.InAuthentication.rawValue {
			// 认证申请中
			self.mTableView.hidden = true
			self.labelSuccessTips.hidden = false
			self.labelSuccessTips.text = "身份认证申请中"
		} else {
			// 认证未通过或者没有认证
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确认", style: UIBarButtonItemStyle.Done, target: self, action: #selector(AuthenticationVC.complete))
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

	/**
	 选择图片
	 */
	func selectImageFromLibrary() -> Void {
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
	 检查资料是否填写完整

	 - returns: 完整返回true
	 */
	func checkProfileCompleted() -> Bool {
		for flag in photoSelectedArray {
			if !flag {
				return false
			}
		}

		return true
	}

	/**
	 完成事件
	 */
	func complete() -> Void {
		// 检查资料是否填写完整
		if !checkProfileCompleted() {
			Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
			return
		}

		// 发起申请
	}

}

extension AuthenticationVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataArray.count;
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE, forIndexPath: indexPath) as! AuthenticationTableViewCell

		cell.labelTips.text = self.dataArray[indexPath.row];

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		curIndexPath = indexPath;
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.selectImageFromLibrary()
	}
}

extension AuthenticationVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate {
	// pragma mark VPImageCropperDelegate
	func imageCropper(cropperViewController: VPImageCropperViewController!, didFinished editedImage: UIImage!) {
		let cell = mTableView .cellForRowAtIndexPath(curIndexPath) as! AuthenticationTableViewCell
		cell.imageViewShow.image = editedImage
		cropperViewController.dismissViewControllerAnimated(true, completion: nil)
		photoSelectedArray[curIndexPath.row] = true
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