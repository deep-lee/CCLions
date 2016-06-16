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
import SwiftyJSON
import MapKit

class Util {
	static let LOINGED_USER_KEY = "loginedUser"
	static let ORIGINAL_MAX_WIDTH: CGFloat = 640.0
	static let COMPANY_MAX_PHOTO_COUNT = 5
	static let MAP_LIMIT_LENGTH = 20000 // 周边公司的距离
	static let FLURRY_API_KEY = "59GB5JNP8FSS3ZHGMW8D " // Flurry 统计Key
	static let MOB_API_KEY = "572ee078e0f55a962d000682" // MOB 统计Key
	static let INDUSTRY = [
		"互联网", "教育", "房地产", "餐饮", "金融", "汽车", "快消", "其他"
	]

	static let SEX = [
		"女", "男"
	]

	static let SETTING1 = [
        "修改密码"
	]

	static let SETTING2 = [
		"退出登录"
	]

	static let SETTING_ARRAY = [
		Util.SETTING1, Util.SETTING2
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
	 登出
	 */
	static func loginOut() {
		// 清空登录的用户信息
		clearLoginedUser()
	}

	static func hasUserCompletedInfo() -> Bool {
		let user = Util.getLoginedUser()
		if user?.name != nil {
			return true
		}

		return false
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

	/**
	 从JSON中解析Project

	 - parameter item: json

	 - returns: 项目
	 */
	static func getProjectFromJson(item: JSON) -> Project {
		let project = Project(
			id: item["id"].intValue,
			title: item["title"].stringValue,
			time: item["time"].stringValue,
			launcher_id: item["launcher_id"].intValue,
			favorite: item["favorite"].intValue,
			cover_image: item["cover_image"].stringValue,
			details_page: item["details_page"].stringValue,
			project_type: item["project_type"].intValue,
			fundraising_amount: item["fundraising_amount"].intValue,
			has_raised_amount: item["has_raised_amount"].intValue,
			withdraw_amount: item["withdraw_amount"].intValue,
			apply_for_other: item["apply_for_other"].intValue,
			aided_person_id_num: item["aided_person_id_num"].stringValue,
			aided_person_id_card_photo: item["aided_person_id_card_photo"].stringValue,
			left_time: item["left_time"].intValue,
			sponsorship_company_id: item["sponsorship_company_id"].intValue,
			create_time: item["create_time"].stringValue,
			name: item["name"].stringValue,
			header: item["header"].stringValue
		)

		return project
	}

	/**
	 从JSON中解析出User Model

	 - parameter data: JOSN

	 - returns: User
	 */
	static func getUserFromJson(data: JSON) -> User {
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

		return user
	}

	/**
	 从JSON中解析出Donation Model

	 - parameter item: JSON

	 - returns: Donation  Model
	 */
	static func getDoantionFromJson(item: JSON) -> Donation {
		let donation = Donation(
			id: item["id"].intValue,
			header: item["header"].stringValue,
			name: item["name"].stringValue,
			user_type: item["user_type"].intValue,
			user_id: item["user_id"].intValue,
			project_id: item["project_id"].intValue,
			amount: item["amount"].intValue,
			application: item["application"].stringValue)

		return donation
	}

	/**
	 从JSON中解析出Withdraw Model

	 - parameter item: JSON

	 - returns: Model
	 */
	static func getWithdrawFromJson(item: JSON) -> Withdraw {
		let withdraw = Withdraw(
			id: item["id"].intValue,
			name: item["name"].stringValue,
			header: item["header"].stringValue,
			contact: item["contact"].stringValue,
			user_type: item["user_type"].intValue,
			user_id: item["user_id"].intValue,
			project_id: item["project_id"].intValue,
			amount: item["amount"].intValue,
			application: item["application"].stringValue,
			prove: item["prove"].stringValue,
			status: item["status"].intValue,
			message: item["message"].stringValue
		)

		return withdraw
	}

	/**
	 从JSON中解析出Comment Model

	 - parameter item: JSON

	 - returns: Model
	 */
	static func getCommentFromJson(item: JSON) -> Comment {
		let comment = Comment(
			id: item["id"].intValue,
			header: item["header"].stringValue,
			name: item["name"].stringValue,
			user_type: item["user_type"].intValue,
			project_id: item["project_id"].intValue,
			user_id: item["user_id"].intValue,
			content: item["content"].stringValue,
			create_time: item["create_time"].stringValue
		)

		return comment
	}

	static func getTimeFromString(string: String) -> String {
		let date = NSDate(string: string, formatString: "yyyy-MM-dd HH:mm:ss")

		return date.timeAgoSinceNow()
	}

	/**
	 从JOSN中解析出DonationSuggestionMoney

	 - parameter item: JSON

	 - returns: MODEL
	 */
	static func getDonationSuggestMoneyFromJson(item: JSON) -> DonationSuggestionMoney {
		let suggest = DonationSuggestionMoney(
			id: item["id"].intValue,
			amount: item["amount"].intValue,
			create_time: item["create_time"].stringValue
		)

		return suggest
	}

	/**
	 从JSON中解析出Company

	 - parameter data: JSON

	 - returns: Model
	 */
	static func getCompanyFromJson(data: JSON) -> Company {
		let company = Company(
			id: data["id"].intValue,
			user_id: data["user_id"].intValue,
			company_name: data["company_name"].stringValue,
			address_longitude: data["address_longitude"].stringValue,
			address_latitude: data["address_latitude"].stringValue,
			address_position: data["address_position"].stringValue,
			business_scope: data["business_scope"].stringValue,
			industry: data["industry"].intValue,
			show_photo: data["show_photo"].stringValue,
			introduction: data["introduction"].stringValue,
			contact: data["contact"].stringValue,
			create_time: data["create_time"].stringValue,
			update_time: data["update_time"].stringValue,
			company_logo: data["company_logo"].stringValue,
			hits: data["hits"].intValue
		)

		return company
	}

	/**
	 获取两点之间的距离

	 - parameter fromLocation: 起点
	 - parameter toLocation:   终点

	 - returns: 距离
	 */
	static func diatanceFromLocation(fromLocation: CLLocation, toLocation: CLLocation) -> CLLocationDistance {
		let distance = fromLocation.distanceFromLocation(toLocation)
		return distance
	}

	static func getAnnotationFromComapny(company: Company) -> MAAnnotation {
		let annotation = MAPointAnnotation()
		let coordinate = CLLocationCoordinate2D(latitude: Double(company.address_latitude)!, longitude: Double(company.address_longitude)!)
		annotation.coordinate = coordinate
		annotation.title = company.company_name
		annotation.subtitle = company.address_position

		return annotation
	}

	static func getSupportedProjectFromJson(item: JSON) -> SupportedProject {
		let supportedProject = SupportedProject(
			id: item["id"].intValue,
			title: item["title"].stringValue,
			time: item["time"].stringValue,
			launcher_id: item["launcher_id"].intValue,
			favorite: item["favorite"].intValue,
			cover_image: item["cover_image"].stringValue,
			details_page: item["details_page"].stringValue,
			project_type: item["project_type"].intValue,
			fundraising_amount: item["fundraising_amount"].intValue,
			has_raised_amount: item["has_raised_amount"].intValue,
			withdraw_amount: item["withdraw_amount"].intValue,
			apply_for_other: item["apply_for_other"].intValue,
			aided_person_id_num: item["aided_person_id_num"].stringValue,
			aided_person_id_card_photo: item["aided_person_id_card_photo"].stringValue,
			left_time: item["left_time"].intValue,
			sponsorship_company_id: item["sponsorship_company_id"].intValue,
			create_time: item["create_time"].stringValue,
			name: item["name"].stringValue,
			header: item["header"].stringValue,
			amount: item["amount"].intValue,
			application: item["application"].stringValue
		)
        
        return supportedProject
	}

    static func getWithdrawSelfFromJson(item: JSON) -> WithdrawSelf {
        let withdraw = WithdrawSelf(
            id: item["id"].intValue,
            contact: item["contact"].stringValue,
            user_id: item["user_id"].intValue,
            project_id: item["project_id"].intValue,
            amount: item["amount"].intValue,
            application: item["application"].stringValue,
            prove: item["prove"].stringValue,
            status: item["status"].intValue,
            message: item["message"].stringValue,
            title: item["title"].stringValue
        )
        
        return withdraw
    }
    
    static func getWithdrawStatusString(status: Int) -> String {
        
        var result = ""
        
        switch status {
        case WithdrawStatus.ApplyIn.rawValue:
            result = "申请中"
        case WithdrawStatus.ApplyFail.rawValue:
            result = "申请不通过"
        case WithdrawStatus.ApplyHandle.rawValue:
            result = "正在处理中"
        case WithdrawStatus.ApplyAgreeNotPay.rawValue:
            result = "申请通过，正在联系提款人"
        case WithdrawStatus.ApplyPayed.rawValue:
            result = "申请完成"
        default:
            break
        }
        
        return result
    }
    
}
