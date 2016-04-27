//
//  SearchCompanyViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/9.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class SearchCompanyViewController: UIViewController {
	@IBOutlet var collectionView: UICollectionView!
	var dataArray1: [(String, String)]!
	var dataArray2: [Company]!
	var cellItemSize: CGSize!
	let kHeaderIdentifier = "kHeaderIdentifier"
	let reuseIdentifier = "SearchCollectionViewCell"

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		initCollectionView()
	}

	func initCollectionView() -> Void {
		self.dataArray1 = [(String, String)]()
		self.dataArray2 = [Company]()
		let screenWidth = UIScreen.mainScreen().bounds.size.width
		self.cellItemSize = CGSizeMake(CGFloat((screenWidth - 30) / 3), CGFloat((screenWidth - 30) / 3))
		self.collectionView.registerClass(HeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderIdentifier)
	}

	func initData() -> Void {
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

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}

extension SearchCompanyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 2
	}

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if section == 0 {
			return self.dataArray1.count
		} else {
			return self.dataArray2.count
		}
	}

	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderIdentifier, forIndexPath: indexPath) as! HeaderView

		return headerView
	}

	func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
		return self.cellItemSize
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! SearchCollectionViewCell
		if indexPath.section == 0 {
			cell.showImageView.sd_setImageWithURL(NSURL(string: self.dataArray1[indexPath.row].0))
			cell.showLabel.text = self.dataArray1[indexPath.row].1
		} else if indexPath.section == 1 {
			cell.showImageView.sd_setImageWithURL(NSURL(string: self.dataArray2[indexPath.row].show_photo))
			cell.showLabel.hidden = true
		}

		return cell
	}
}
