//
//  CompanyInfoViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/6.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyDrop
import SwiftyJSON

class CompanyInfoViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	var company: Company?
	var hasUploadedPhotoArray: [String]!
	var dataArray: [(String, String)]!
	var selectedPhotos: [UIImage] = [UIImage]()
	var selectedIndustry = -1
	var selectedAnnotation: MAAnnotation?
	var selectedLogoImage: UIImage?
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.initData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/**
	 初始化数据
	 */
	func initData() {
		self.hasUploadedPhotoArray = company?.show_photo.componentsSeparatedByString(";")
		self.hasUploadedPhotoArray.removeLast()
		self.dataArray = [(String, String)]()
		self.dataArray.append(("公司名称", (company?.company_name)!))
		self.dataArray.append(("公司地址", (company?.address_position)!))
		self.dataArray.append(("经营范围", (company?.business_scope)!))
		self.selectedIndustry = (company?.industry)!
		self.dataArray.append(("所属行业", Util.INDUSTRY[(company?.industry)!]))
		self.dataArray.append(("简介", (company?.introduction)!))
		self.dataArray.append(("联系方式", (company?.contact)!))
		self.dataArray.append(("展示照片", "已选择\(self.hasUploadedPhotoArray.count)张照片"))
		self.dataArray.append(("公司Logo", "已选择公司Logo"))
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

	func goToEditTextViewVC(row: Int) -> Void {
		let editTextViewViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EditTextViewViewController") as! EditTextViewViewController
		editTextViewViewController.row = row
		editTextViewViewController.contentString = self.dataArray[row].1
		editTextViewViewController.setClosure(editTextViewCallBack)
		editTextViewViewController.title = self.dataArray[row].0
		self.navigationController?.pushViewController(editTextViewViewController, animated: true)
	}

	func editTextViewCallBack(string: String, row: Int) -> Void {
		if row == 4 {
			self.dataArray[row].1 = string
			self.tableView.reloadData()
		}
	}

	func goToEditSelectDataVC(row: Int) -> Void {
		let editSelectDataViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditSelectDataViewController") as! EditSelectDataViewController
		editSelectDataViewController.title = self.dataArray[row].0
		editSelectDataViewController.dataArray = Util.INDUSTRY
		editSelectDataViewController.selectedIndex = self.selectedIndustry
		editSelectDataViewController.row = row
		editSelectDataViewController.setClosure(editSelectDataCallBack)
		self.navigationController?.pushViewController(editSelectDataViewController, animated: true)
	}

	func editSelectDataCallBack(row: Int, selectedRow: Int) -> Void {
		if row == 3 {
			self.selectedIndustry = selectedRow
			self.dataArray[3].1 = Util.INDUSTRY[selectedRow]
			self.tableView.reloadData()
		}
	}

	func goToPickPositionVC(row: Int) -> Void {
		let pickPositionVC = PickPositionOnMapViewController()
		pickPositionVC.title = self.dataArray[row].0
		pickPositionVC.row = row
		pickPositionVC.setClosure(pickPositionCallBack)
		self.navigationController?.pushViewController(pickPositionVC, animated: true)
	}

	func pickPositionCallBack(row: Int, annotation: MAAnnotation) -> Void {
		self.dataArray[row].1 = annotation.title!
		self.selectedAnnotation = annotation
		self.tableView.reloadData()
	}

	func goToSelectMultiPhotoVC(row: Int) -> Void {
		let updateCompanyPhotoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UpdateCompanyPhotoViewController") as! UpdateCompanyPhotoViewController
		updateCompanyPhotoViewController.title = self.dataArray[row].0
		updateCompanyPhotoViewController.hasUploadedPhoto = self.hasUploadedPhotoArray
		updateCompanyPhotoViewController.dataArray = self.selectedPhotos
		updateCompanyPhotoViewController.setClosure(updateCompanyPhotoCallBack)

		self.navigationController?.pushViewController(updateCompanyPhotoViewController, animated: true)
	}

	func updateCompanyPhotoCallBack(hasUplodedPhotos: [String], var dataArray: [UIImage]) -> Void {
		dataArray.removeLast()
		self.selectedPhotos = dataArray
		self.hasUploadedPhotoArray = hasUplodedPhotos
		self.dataArray[6].1 = "已选择\(self.selectedPhotos.count + self.hasUploadedPhotoArray.count)张照片"
		self.tableView.reloadData()
	}

	func goToSelectLogoVC(row: Int) -> Void {
		let selectCompanyLogoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SelectCompanyLogoViewController") as! SelectCompanyLogoViewController
		selectCompanyLogoViewController.title = self.dataArray[row].0
		if self.selectedLogoImage != nil {
			selectCompanyLogoViewController.logoImageView.image = self.selectedLogoImage
		} else {
			selectCompanyLogoViewController.hasUploadedLogo = self.company?.company_logo
		}
		selectCompanyLogoViewController.setClosure(selectLogoCallBack)
		selectCompanyLogoViewController.row = row

		self.navigationController?.pushViewController(selectCompanyLogoViewController, animated: true)
	}

	func selectLogoCallBack(row: Int, headerChanged: Bool, logoImage: UIImage?) -> Void {
		if headerChanged {
			self.selectedLogoImage = logoImage
			self.dataArray[row].1 = "已选择Logo"
			self.tableView.reloadData()
		}
	}

	@IBAction func save(sender: AnyObject) {
		// 首先检查资料是否填写完整
		if !self.checkCompleted() {
			Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
			return
		}
		SVProgressHUD.showWithStatus(Tips.UPDATING_COMPANY)
		// 资料填写完整后，首先看是否有图片需要上传
		if self.selectedPhotos.count != 0 { // 有图片需要上传
			Alamofire.upload(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_UPLOAD_COMPANY_SHOW_IMAGE.rawValue, multipartFormData: { multipartFormData in
				var index = 0
				for image in self.selectedPhotos {
					// multipartFormData.appendBodyPart(data: UIImageJPEGRepresentation(image, 0.5)!, name: "file\(index)")
					multipartFormData.appendBodyPart(data: UIImageJPEGRepresentation(image, 0.5)!, name: "file\(index)", fileName: "file\(index)", mimeType: "image/jpeg")
					index += 1
				}
			}) { (encodingResult) in
				switch encodingResult {
				case .Success(let upload, _, _):
					upload.responseJSON { response in
						if let value = response.result.value {
							let json = JSON(value)
							let code = json["code"].intValue
							if code == 200 {
								let data = json["data"].stringValue
								print("收到的图片地址为：" + data)
								var photoAddress = ""
								if self.hasUploadedPhotoArray.count != 0 {
									for item in self.hasUploadedPhotoArray {
										photoAddress += item
										photoAddress += ";"
									}
								}
								photoAddress += data

								// 判断是否需要更新了logo
								if self.selectedLogoImage != nil {
									// 更新了Logo
									// 上传新的Logo
									self.uploadCompanyLogo(photoAddress)
								} else {
									// 直接请求更新公司信息
									self.requestUpdateCompany(photoAddress, logoAddress: (self.company?.company_logo)!)
								}
							} else {
								Drop.down(Tips.UPLOAD_PHOTO_FAIL, state: DropState.Error)
								SVProgressHUD.dismiss()
							}
						} else {
							Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
							SVProgressHUD.dismiss()
						}
					}
				case .Failure(_):
					Drop.down(Tips.UPLOAD_PHOTO_FAIL, state: DropState.Error)
					SVProgressHUD.dismiss()
				}
			}
		} else { // 如果没有照片需要上传
			var photoAddress = ""
			for item in self.hasUploadedPhotoArray {
				photoAddress += item
				photoAddress += ";"
			}

			// 判断是否需要更新了logo
			if self.selectedLogoImage != nil {
				// 更新了Logo
				// 上传新的Logo
				self.uploadCompanyLogo(photoAddress)
			} else {
				// 直接请求更新公司信息
				self.requestUpdateCompany(photoAddress, logoAddress: (self.company?.company_logo)!)
			}
		}
	}

	/**
	 上传公司logo

	 - parameter photoAddress: 公司展示照片地址
	 */
	func uploadCompanyLogo(photoAddress: String) -> Void {
		Alamofire.upload(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ACCEPT_COMPANY_IMAGE_iOS.rawValue, data: UIImageJPEGRepresentation(self.selectedLogoImage!, 0.5)!)
			.responseJSON { (response) in
				if let value = response.result.value {
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 {
						let logoAddress = HttpRequest.HTTP_ADDRESS + json["data"].stringValue
						// 发起请求
						self.requestUpdateCompany(photoAddress, logoAddress: logoAddress)
					} else {
						Drop.down(Tips.UPLOAD_PHOTO_FAIL, state: DropState.Error)
						SVProgressHUD.dismiss()
					}
				} else {
					Drop.down(Tips.UPLOAD_PHOTO_FAIL, state: DropState.Error)
					SVProgressHUD.dismiss()
				}
		}
	}

	/**
	 请求更新公司信息

	 - parameter photoAddress: 公司照片展示地址
	 */
	func requestUpdateCompany(photoAddress: String, logoAddress: String) -> Void {
        let address_longitude = self.selectedAnnotation == nil ? (self.company?.address_longitude)! : String(self.selectedAnnotation!.coordinate.longitude)
        let address_latitude = self.selectedAnnotation == nil ? (self.company?.address_latitude)! : String(self.selectedAnnotation!.coordinate.latitude)
        let address_position = self.selectedAnnotation == nil ? (self.company?.address_position)! : self.selectedAnnotation?.title
		let paras: [String: AnyObject] = [
			"company_id": (self.company?.id)!,
			"company_name": self.dataArray[0].1,
			"address_longitude": address_longitude,
			"address_latitude": address_latitude,
			"address_position": address_position!,
			"business_scope": self.dataArray[2].1,
			"industry": self.selectedIndustry,
			"show_photo": photoAddress,
			"introduction": self.dataArray[4].1,
			"contact": self.dataArray[5].1,
			"company_logo": logoAddress
		]

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_UPDATE_COMPANY_INFO.rawValue, parameters: paras)
			.responseJSON { (response) in
				if let value = response.result.value {
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 {
						// 更新公司成功
						Drop.down(Tips.UPDATE_COMPANY_SUCCESS, state: DropState.Success)
						self.navigationController?.popViewControllerAnimated(true)
						SVProgressHUD.dismiss()
					} else {
						Drop.down(Tips.UPDATE_COMPANY_FAIL, state: DropState.Error)
						SVProgressHUD.dismiss()
					}
				} else {
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
					SVProgressHUD.dismiss()
				}
		}
	}

	/**
	 检查资料是否填写完整

	 - returns:
	 */
	func checkCompleted() -> Bool {
		for item in self.dataArray {
			if item.1 == "" {
				return false
			}
		}

		if (self.selectedPhotos.count + self.hasUploadedPhotoArray.count) == 0 {
			return false
		}

		return true
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

extension CompanyInfoViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("CompanyInfoTableViewCell", forIndexPath: indexPath)
		let dataItem = self.dataArray[indexPath.row]
		cell.textLabel?.text = dataItem.0
		cell.detailTextLabel?.text = dataItem.1

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		switch indexPath.row {
		case 0, 2, 5:
			self.goToEditTextFieldVC(indexPath.row)
		case 1:
			self.goToPickPositionVC(indexPath.row)
		case 3:
			self.goToEditSelectDataVC(indexPath.row)
		case 4:
			self.goToEditTextViewVC(indexPath.row)
		case 6:
			self.goToSelectMultiPhotoVC(indexPath.row)
		case 7:
			self.goToSelectLogoVC(indexPath.row)
		default:
			return
		}
	}
}
