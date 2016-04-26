//
//  UpdateCompanyPhotoViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/25.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop
import SwiftyJSON
import Alamofire

class UpdateCompanyPhotoViewController: UIViewController {
	@IBOutlet var collectionView: UICollectionView!

	var dataArray: [UIImage]!
	var hasUploadedPhoto: [String]!
	let reuseIdentifier = "PhotoCollectionViewCell"
	var cellItemSize: CGSize!
	var myClosure: updateShowPhotoSendValues!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.initData()
		print("\(self.dataArray.count + self.hasUploadedPhoto.count)")
	}

	func initData() -> Void {
		// 每行现实2张图片
		let screenWidth = UIScreen.mainScreen().bounds.size.width
		self.cellItemSize = CGSizeMake(CGFloat((screenWidth - 30) / 3), CGFloat((screenWidth - 30) / 3))

		self.dataArray.append(UIImage(named: "icon-add-normal")!)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
	func setClosure(closure: updateShowPhotoSendValues) -> Void {
		self.myClosure = closure
	}

	func selectPhoto() -> Void {
		let photoController = ZZPhotoController()
		photoController.selectPhotoOfMax = Util.COMPANY_MAX_PHOTO_COUNT - self.dataArray.count - self.hasUploadedPhoto.count + 1
		photoController.showIn(self) { (responseObject) in
			self.dataArray.insertContentsOf(responseObject as! [UIImage], at: 0)
			self.collectionView.reloadData()
		}
	}

	func goToShowPhotoVC() -> Void {
		let updateShowImageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UpdateShowImageViewController") as! UpdateShowImageViewController
		updateShowImageViewController.dataArray = self.dataArray
		updateShowImageViewController.hasUploadedPhotos = self.hasUploadedPhoto
		updateShowImageViewController.setClosure(updateShowPhotoCallBack)
		self.navigationController?.pushViewController(updateShowImageViewController, animated: true)
	}

	func updateShowPhotoCallBack(hasUplodedPhotos: [String], dataArray: [UIImage]) -> Void {
		self.dataArray = dataArray
		self.dataArray.append(UIImage(named: "icon-add-normal")!)
		self.hasUploadedPhoto = hasUplodedPhotos
		self.collectionView.reloadData()
	}

	@IBAction func save(sender: AnyObject) {
		if (self.myClosure != nil) {
			myClosure(hasUplodedPhotos: self.hasUploadedPhoto, dataArray: self.dataArray)
			self.navigationController?.popViewControllerAnimated(true)
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

extension UpdateCompanyPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataArray.count + self.hasUploadedPhoto.count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell

		// 如果是已经上传了的图片
		if indexPath.row <= self.hasUploadedPhoto.count - 1 {
			cell.photoImageView.sd_setImageWithURL(NSURL(string: self.hasUploadedPhoto[indexPath.row]))
		} else {
			cell.photoImageView.image = self.dataArray[indexPath.row - self.hasUploadedPhoto.count]
		}

		return cell
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		if (self.dataArray.count + self.hasUploadedPhoto.count - 1) == indexPath.row {
			if self.dataArray.count + self.hasUploadedPhoto.count <= Util.COMPANY_MAX_PHOTO_COUNT {
				self.selectPhoto()
			} else {
				Drop.down(Tips.SELECT_MULTI_PHOTO_LESS_THAN_FIVE, state: DropState.Warning)
			}
		} else {
			self.goToShowPhotoVC()
		}

		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
	}

	func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
		return self.cellItemSize
	}
}
