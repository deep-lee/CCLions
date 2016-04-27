//
//  SelectCompanyLogoViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/27.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices

class SelectCompanyLogoViewController: UIViewController {
	@IBOutlet var logoImageView: UIImageView!
	var hasUploadedLogo: String?
	var headerChanged = false
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.initView()
	}

	/**
	 初始化界面
	 */
	func initView() -> Void {
		if hasUploadedLogo != nil { // 更新Logo
			self.logoImageView.sd_setImageWithURL(NSURL(string: self.hasUploadedLogo!))
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func selectLogo(sender: AnyObject) {
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
	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}

extension SelectCompanyLogoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate {
	// pragma mark VPImageCropperDelegate
	func imageCropper(cropperViewController: VPImageCropperViewController!, didFinished editedImage: UIImage!) {
		self.logoImageView.image = editedImage
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
