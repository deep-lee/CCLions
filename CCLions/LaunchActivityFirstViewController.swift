//
//  LaunchActivityFirstViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/6.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import Alamofire
import SwiftyDrop
import SwiftyJSON

class LaunchActivityFirstViewController: WPEditorViewController {
	var videoPressCache: NSCache = NSCache()
	var mediaAdded: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.delegate = self
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
	// 显示图片选择器
	func showPhotoPicker() {
		let picker = UIImagePickerController()
		picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		picker.delegate = self
		picker.allowsEditing = false
		picker.navigationBar.translucent = false
		picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
		picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(picker.sourceType)!
		self.navigationController?.presentViewController(picker, animated: true, completion: nil)
	}

	// 添加资源到编辑器中
	func addAssetToContent(assertURL: NSURL) {
		let assets = PHAsset.fetchAssetsWithALAssetURLs([assertURL], options: nil)
		if assets.count < 1 {
			return
		}
		let asset = assets.firstObject as! PHAsset
		if asset.mediaType == PHAssetMediaType.Video {
			Drop.down(Tips.ACTIVITY_VIDEO_NOT_ALLOWED, state: DropState.Info)
		} else if asset.mediaType == PHAssetMediaType.Image {
			self.addImageAssetToContent(asset)
		}
	}

//	// 添加视频
//	func addVideoAssetToContent(originalAsset: PHAsset) {
//		let options = PHImageRequestOptions()
//		options.synchronous = false
//		options.networkAccessAllowed = true
//		options.resizeMode = PHImageRequestOptionsResizeMode.Fast
//		options.version = PHImageRequestOptionsVersion.Current
//		options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
//		let videoID = NSUUID().UUIDString
//		let videoPath = "\(NSTemporaryDirectory())\(videoID).mov"
//		PHImageManager.defaultManager().requestImageForAsset(originalAsset, targetSize: UIScreen.mainScreen().bounds.size, contentMode: PHImageContentMode.AspectFit, options: options) { (image, info) -> Void in
//			let data = UIImageJPEGRepresentation(image!, 0.7)
//			let posterImagePath = "\(NSTemporaryDirectory())/\(NSUUID().UUIDString).jpg"
//			data?.writeToFile(posterImagePath, atomically: true)
//			dispatch_async(dispatch_get_main_queue(), { () -> Void in
//				// 上传视频
//				let progress = NSProgress(parent: nil, userInfo: [
//					"videoID": videoID,
//					"url": videoPath,
//					"poster": posterImagePath
//				])
//				progress.cancellable = true
//				Alamofire.upload(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ACCEPT_ACTIVITY_VIDEO.rawValue, data: NSData(contentsOfFile: videoPath)!)
//					.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
//						progress.totalUnitCount = totalBytesExpectedToWrite
//						progress.completedUnitCount = totalBytesWritten
//						print(progress.fractionCompleted)
//
//						dispatch_async(dispatch_get_main_queue(), { () -> Void in
//							self.editorView.setProgress(progress.fractionCompleted, onVideo: videoID)
//							self.mediaAdded[videoID] = progress
//						})
//				}
//					.responseJSON { response in
//						print(response)
//						// 返回的不为空
//						if let value = response.result.value {
//							// 解析json
//							let json = JSON(value)
//							let code = json["code"].intValue
//
//							print(json)
//
//							// 获取成功
//							if code == 200 {
//								let data = json["data"].stringValue
//								let url = HttpRequest.HTTP_ADDRESS + data
//								self.editorView.replaceLocalVideoWithID(videoID, forRemoteVideo: url, remotePoster: posterImagePath, videoPress: videoID)
//
//								self.videoPressCache.setObject([
//									"source": url,
//									"poster": posterImagePath
//									], forKey: videoID)
//							}
//						}
//				}
//			})
//		}
//	}

	func addImageDataToContent(imageData: NSData) -> Void {
		SVProgressHUD.showWithStatus(Tips.UPLOADING_PHOTO)
		let imageID = NSUUID().UUIDString
		Alamofire.upload(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ACCEPT_ACTIVITY_IMAGE.rawValue, data: imageData)
			.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in

				let progress: Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
				let progressStr = NSString(format: "%.0f", progress * 100)
				SVProgressHUD.showWithStatus(Tips.UPLOADING_PHOTO + " " + (progressStr as String) + "%")
		}
			.responseJSON { response in
				print(response)
				// 返回的不为空
				if let value = response.result.value {
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue
					// 获取成功
					if code == 200 {
						let data = json["data"].stringValue
						let url = HttpRequest.HTTP_ADDRESS + data
						print(url)
						dispatch_async(dispatch_get_main_queue(), {
							print("正在替换照片")
							print(imageID)
							let mediaId = data.substring(16)
							print(mediaId)
							// self.editorView.replaceLocalImageWithRemoteImage(url, uniqueId: imageID, mediaId: mediaId)
							self.editorView.insertImage(url, alt: "")
							// self.editorView.removeImage(imageID)
						})
					}
				} else {
					Drop.down(Tips.UPLOAD_PHOTO_FAIL, state: DropState.Error)
				}

				SVProgressHUD.dismiss()
		}
	}

	// 添加照片
	func addImageAssetToContent(asset: PHAsset) {
		let options = PHImageRequestOptions()
		options.synchronous = false
		options.networkAccessAllowed = true
		options.resizeMode = PHImageRequestOptionsResizeMode.Exact
		options.version = PHImageRequestOptionsVersion.Current
		options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat

		PHImageManager.defaultManager().requestImageDataForAsset(asset, options: options) { (imageData, dataUTI, orientation, info) in
			self.addImageDataToContent(imageData!)
		}
	}

	func timerFireMethod(timer: NSTimer) {
		print("调用了")
		let progress = timer.userInfo as! NSProgress
		progress.completedUnitCount += 1
		let imageID = progress.userInfo["imageID"] as! String?
		if (imageID != nil) {
			self.editorView.setProgress(progress.fractionCompleted, onImage: imageID)
			if progress.fractionCompleted >= 1 {
				self.editorView.replaceLocalImageWithRemoteImage(NSURL(fileURLWithPath: progress.userInfo["url"] as! String).absoluteString, uniqueId: imageID, mediaId: imageID)
				timer.invalidate()
			}

			return
		}

		let videoID = progress.userInfo["videoID"] as! String?
		if (videoID != nil) {
			self.editorView.setProgress(progress.fractionCompleted, onVideo: videoID)
			if progress.fractionCompleted >= 1 {
				let videoURL = NSURL(fileURLWithPath: progress.userInfo["url"] as! String).absoluteString
				let posterURL = NSURL(fileURLWithPath: progress.userInfo["poster"] as! String).absoluteString
				self.editorView.replaceLocalVideoWithID(videoID, forRemoteVideo: videoURL, remotePoster: posterURL, videoPress: videoID)
				self.videoPressCache.setObject([
					"source": videoURL,
					"poster": posterURL
					], forKey: videoID!)
				timer.invalidate()
			}

			return
		}
	}

	@IBAction func next(sender: AnyObject) {
		// 首先判断内容是否填写完整
		if !hasCompleted() {
			Drop.down(Tips.ACTIVITY_CONTENT_NOT_COMPLETED, state: DropState.Warning)
			return
		}

		// 进入到下一界面
		let moreInfoActivityViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MoreInfoActivityViewController") as! MoreInfoActivityViewController
		moreInfoActivityViewController.activityTheme = self.editorView.titleField.html()
		moreInfoActivityViewController.activityContent = self.editorView.contentField.html()
		moreInfoActivityViewController.title = "更多信息"
		moreInfoActivityViewController.setClosure(publishActivityCallBack)
		self.navigationController?.pushViewController(moreInfoActivityViewController, animated: true)
	}

	/**
	 发表活动回调
	 */
	func publishActivityCallBack() -> Void {
		self.editorView.titleField.setText("")
		self.editorView.contentField.setText("")
	}

	/**
	 判断内容是否填写完整

	 - returns:
	 */
	func hasCompleted() -> Bool {
		if self.editorView.titleField.html().characters.count > 0 && self.editorView.contentField.html().characters.count > 0 {
			return true
		}

		return false
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

extension LaunchActivityFirstViewController: WPEditorViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	// 开始编辑
	func editorDidBeginEditing(editorController: WPEditorViewController!) {
		print("Editor did begin editing.")
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
			let assetURL = info[UIImagePickerControllerReferenceURL] as! NSURL
			print(assetURL)
			self.addAssetToContent(assetURL)
		})
	}

	// 添加图片
	func editorDidPressMedia(editorController: WPEditorViewController!) {
		self.showPhotoPicker()
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

