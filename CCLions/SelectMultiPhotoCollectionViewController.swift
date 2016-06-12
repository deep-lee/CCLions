//
//  SelectMultiPhotoCollectionViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/23.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop
import SwiftyJSON
import Alamofire

class SelectMultiPhotoCollectionViewController: UIViewController {
	var dataArray: [UIImage]!
	let reuseIdentifier = "PhotoCollectionViewCell"
	var cellItemSize: CGSize!
	var myClosure: showPhotoSendValues!

	@IBOutlet var collectionView: UICollectionView!
	override func viewDidLoad() {
		super.viewDidLoad()

		self.initData()
        initWeight()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		if (myClosure != nil) {
			myClosure(dataArray: self.dataArray)
		}
	}

	func initData() -> Void {
		// 每行现实2张图片
		let screenWidth = UIScreen.mainScreen().bounds.size.width
		self.cellItemSize = CGSizeMake(CGFloat((screenWidth - 30) / 3), CGFloat((screenWidth - 30) / 3))

		self.dataArray.append(UIImage(named: "icon-add-normal")!)
	}
    
    func initWeight() -> Void {
        let next = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SelectMultiPhotoCollectionViewController.save(_:)))
        self.navigationItem.rightBarButtonItem = next
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func selectPhoto() -> Void {
		let photoController = ZZPhotoController()
		photoController.selectPhotoOfMax = Util.COMPANY_MAX_PHOTO_COUNT - self.dataArray.count + 1
		photoController.showIn(self) { (responseObject) in
			self.dataArray.insertContentsOf(responseObject as! [UIImage], at: 0)
			self.collectionView.reloadData()
		}
	}

	func goToShowPhotoVC() -> Void {
		let showImageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ShowImageViewController") as! ShowImageViewController
		showImageViewController.dataArray = self.dataArray
		showImageViewController.setClosure(showPhotoCallBack)
		self.navigationController?.pushViewController(showImageViewController, animated: true)
	}

	func showPhotoCallBack(dataArray: [UIImage]) -> Void {
		self.dataArray = dataArray
		self.dataArray.append(UIImage(named: "icon-add-normal")!)
		self.collectionView.reloadData()
	}

    func save(sender: AnyObject) {
		if (myClosure != nil) {
			myClosure(dataArray: self.dataArray)
			self.navigationController?.popViewControllerAnimated(true)
		}
	}

	func setClosure(closure: showPhotoSendValues) -> Void {
		self.myClosure = closure
	}
	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using [segue destinationViewController].
	 // Pass the selected object to the new view controller.
	 }
	 */
}

extension SelectMultiPhotoCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataArray.count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
		cell.photoImageView.image = self.dataArray[indexPath.row]

		return cell
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		if self.dataArray.count - 1 == indexPath.row {
			if self.dataArray.count <= Util.COMPANY_MAX_PHOTO_COUNT {
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
