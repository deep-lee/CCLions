//
//  File.swift
//  CCLions
//
//  Created by Joseph on 16/4/9.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import AssetsLibrary
import MobileCoreServices
class Util {
	static let LOINGED_USER_KEY = "loginedUser"
	static let ORIGINAL_MAX_WIDTH: CGFloat = 640.0
	static let COMPANY_MAX_PHOTO_COUNT = 5
	static let MAP_LIMIT_LENGTH = 20000 // 周边公司的距离
	static let INDUSTRY = [
		"教育", "房地产", "金融", "电子竞技", "互联网", "食品"
	]

	static let SEX = [
		"女", "男"
	]

	/**
	 判断当前是否有用户登录

	 - returns: 有->yes
	 */
	static func hasUserLogined() -> Bool {
		let data: NSData? = NSUserDefaults.standardUserDefaults().objectForKey(LOINGED_USER_KEY) as? NSData
		if let _ = data {
			return true
		} else {
			return false
		}
	}

	/**
	 获取当前登录的用户

	 - returns: 当前登录的用户对象
	 */
	static func getLoginedUser() -> User? {
		let data: NSData? = NSUserDefaults.standardUserDefaults().objectForKey(LOINGED_USER_KEY) as? NSData
		if let _ = data {
			let user = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! User
			return user
		} else {
			return nil
		}
	}

	/**
	 更新当前登录的用户

	 - parameter user: 当前登录的用户对象
	 */
	static func updateUser(user: User) {
		// 首先清空当前已登录的用户
		clearLoginedUser()

		// 插入用户
		insertUser(user)
	}

	/**
	 清空当前已登录的用户
	 */
	static func clearLoginedUser() {
		if hasUserLogined() { // 当前有用户登录
			NSUserDefaults.standardUserDefaults().removeObjectForKey(LOINGED_USER_KEY)
		}
	}

	/**
	 向存储中插入用户对象

	 - parameter user: 待存储的用户对象
	 */
	static func insertUser(user: User) {
		let data = NSKeyedArchiver.archivedDataWithRootObject(user)
		NSUserDefaults.standardUserDefaults().setObject(data, forKey: LOINGED_USER_KEY)
	}

	/**
	 判断手机号码的合法性

	 - parameter num: 手机号码

	 - returns: 是否合法

	 */
	static func isTelNumber(num: NSString) -> Bool
	{
		let mobile = "^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
		let CM = "^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"
		let CU = "^1(3[0-2]|5[256]|8[56])\\d{8}$"
		let CT = "^1((33|53|8[09])[0-9]|349)\\d{7}$"
		let regextestmobile = NSPredicate(format: "SELF MATCHES %@", mobile)
		let regextestcm = NSPredicate(format: "SELF MATCHES %@", CM)
		let regextestcu = NSPredicate(format: "SELF MATCHES %@", CU)
		let regextestct = NSPredicate(format: "SELF MATCHES %@", CT)
		if ((regextestmobile.evaluateWithObject(num) == true)
			|| (regextestcm.evaluateWithObject(num) == true)
			|| (regextestct.evaluateWithObject(num) == true)
			|| (regextestcu.evaluateWithObject(num) == true))
		{
			return true
		}
		else
		{
			return false
		}
	}

	static func stringFromDate(date: NSDate) -> String {
		let dateFrrmatter = NSDateFormatter()
		dateFrrmatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let dateString = dateFrrmatter.stringFromDate(date)

		return dateString
	}

	/**
	 判断相机是否可以使用

	 - returns:
	 */
	static func isCameraAvailable() -> Bool {
		return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
	}

	/**
	 判断后置摄像头是否可以使用

	 - returns:
	 */
	static func isRearCameraAvailable() -> Bool {
		return UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear)
	}

	/**
	 判断前置摄像头是否可以使用

	 - returns:
	 */
	static func isFrontCameraAvailable() -> Bool {
		return UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)
	}

	/**
	 判断图库是否可以使用

	 - returns:
	 */
	static func isPhotoLibraryAvailable() -> Bool {
		return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
	}

	/**
	 判断相机是否支持拍照

	 - returns:
	 */
	static func doesCameraSupportTakingPhotos() -> Bool {
		return Util.cameraSupportsMedia(kUTTypeImage as String, sourceType: UIImagePickerControllerSourceType.Camera)
	}

	/**
	 判断用户是否有权限从图库选择照片

	 - returns:
	 */
	static func canUserPickVideosFromPhotoLibrary() -> Bool {
		return Util.cameraSupportsMedia(kUTTypeMovie as String, sourceType: UIImagePickerControllerSourceType.PhotoLibrary)
	}

	/**
	 判断相机是否支持媒体类型

	 - parameter paramMediaType: 媒体类型
	 - parameter sourceType:源类型

	 - returns:
	 */
	static func cameraSupportsMedia(paramMediaType: String, sourceType: UIImagePickerControllerSourceType) -> Bool {
		var result = false
		if paramMediaType.characters.count == 0 {
			return false
		}

		let availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(sourceType)
		result = (availableMediaTypes?.contains(paramMediaType))!
		return result
	}

	static func imageByScalingToMaxSize(sourceImage: UIImage) -> UIImage {
		if sourceImage.size.width < Util.ORIGINAL_MAX_WIDTH {
			return sourceImage
		}

		var btWidth: CGFloat = 0.0
		var btHeight: CGFloat = 0.0
		if sourceImage.size.width > sourceImage.size.height {
			btHeight = Util.ORIGINAL_MAX_WIDTH
			btWidth = sourceImage.size.width * (Util.ORIGINAL_MAX_WIDTH / sourceImage.size.height)
		} else {
			btWidth = Util.ORIGINAL_MAX_WIDTH
			btHeight = sourceImage.size.height * (Util.ORIGINAL_MAX_WIDTH / sourceImage.size.width)
		}

		let targetSize = CGSizeMake(btWidth, btHeight)
		return Util.imageByScalingAndCroppingForSourceImage(sourceImage, targetSize: targetSize)
	}

	static func imageByScalingAndCroppingForSourceImage(sourceImage: UIImage, targetSize: CGSize) -> UIImage {
		var newImage: UIImage?
		let imageSize = sourceImage.size
		let width = imageSize.width
		let height = imageSize.height
		let targetWidth = targetSize.width
		let targetHeight = targetSize.height
		var scaleFactor: CGFloat = 0.0
		var scaledWidth = targetWidth
		var scaledHeight = targetHeight
		var thumbnailPoint = CGPointMake(0.0, 0.0)

		if CGSizeEqualToSize(imageSize, targetSize) == false {
			let widthFactor = targetWidth / width
			let heightFactor = targetHeight / height
			if widthFactor > heightFactor {
				scaleFactor = widthFactor
			} else {
				scaleFactor = heightFactor
			}

			scaledWidth = width * scaleFactor
			scaledHeight = height * scaleFactor

			if widthFactor > heightFactor {
				thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
			} else if widthFactor < heightFactor {
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
			}
		}

		UIGraphicsBeginImageContext(targetSize)
		var thumbnailRect = CGRectZero
		thumbnailRect.origin = thumbnailPoint
		thumbnailRect.size.width = scaledWidth
		thumbnailRect.size.height = scaledHeight
		sourceImage.drawInRect(thumbnailRect)
		newImage = UIGraphicsGetImageFromCurrentImageContext()
		if newImage == nil {
			print("缩放失败")
		}
		UIGraphicsEndImageContext()
		return newImage!
	}

	static func fullResolutionImageFromALAsset(asset: ALAsset) -> UIImage {
		let img = UIImage(CGImage: asset.defaultRepresentation().fullScreenImage() as! CGImage)
		return img
	}
}