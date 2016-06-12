//
//  UpdateShowImageViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/25.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

typealias updateShowPhotoSendValues = (hasUplodedPhotos: [String], dataArray: [UIImage]) -> Void
class UpdateShowImageViewController: UIViewController {
	@IBOutlet var scrollView: UIScrollView!
	var dataArray: [UIImage]!
	var hasUploadedPhotos: [String]!
	var currentIndex = 0
	var screenWidth: CGFloat = 0
	var navigationBarHide = false
	var myClosure: updateShowPhotoSendValues!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.screenWidth = self.view.frame.size.width
		if self.dataArray != nil {
			self.dataArray.removeLast()
		}
		self.initScrollView()
        initWeight()
	}

	func initScrollView() -> Void {
		self.title = "\(1) / \(self.dataArray.count + self.hasUploadedPhotos.count)"
		self.scrollView.delegate = self
		for subView in self.scrollView.subviews {
			subView.removeFromSuperview()
		}
		if (self.dataArray != nil) {
			var index = 0

			for address in self.hasUploadedPhotos {
				let imageView = UIImageView(frame: CGRectMake(CGFloat(index) * screenWidth, 0, self.view.frame.size.width, self.view.frame.size.height))
				imageView.sd_setImageWithURL(NSURL(string: address))
				imageView.contentMode = UIViewContentMode.ScaleAspectFit
				self.scrollView.addSubview(imageView)
				index += 1
			}

			for image in self.dataArray {
				let imageView = UIImageView(frame: CGRectMake(CGFloat(index) * screenWidth, 0, self.view.frame.size.width, self.view.frame.size.height))
				imageView.image = image
				imageView.contentMode = UIViewContentMode.ScaleAspectFit
				self.scrollView.addSubview(imageView)
				index += 1
			}

			self.scrollView.contentSize = CGSizeMake(CGFloat(index) * self.screenWidth, self.view.frame.size.height - 48)
		}

		self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UpdateShowImageViewController.scrollViewTaped(_:))))
	}
    
    func initWeight() -> Void {
        let next = UIBarButtonItem(title: "删除", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UpdateShowImageViewController.deleteAction(_:)))
        self.navigationItem.rightBarButtonItem = next
    }

	func setClosure(closure: updateShowPhotoSendValues) -> Void {
		self.myClosure = closure
	}

	func scrollViewTaped(tap: UITapGestureRecognizer) -> Void {
		print("点击了")
		if self.navigationBarHide {
			print("显示")
			self.navigationController?.setNavigationBarHidden(false, animated: true)
			self.navigationBarHide = false
		} else {
			print("隐藏")
			self.navigationController?.setNavigationBarHidden(true, animated: true)
			self.navigationBarHide = true
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    func deleteAction(sender: AnyObject) {
		if currentIndex < self.hasUploadedPhotos.count {
			self.hasUploadedPhotos.removeAtIndex(self.currentIndex)
		} else {
			self.dataArray.removeAtIndex(currentIndex - self.hasUploadedPhotos.count)
		}

		self.initScrollView()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		if (self.myClosure != nil) {
			myClosure(hasUplodedPhotos: self.hasUploadedPhotos, dataArray: self.dataArray)
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

extension UpdateShowImageViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(scrollView: UIScrollView) {
		// print("收到了消息")
		let offsetX = scrollView.contentOffset.x - self.screenWidth * CGFloat(currentIndex)
		let pageWidth = scrollView.frame.size.width
		self.currentIndex = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)) + 1
		self.title = "\(currentIndex + 1) / \(self.dataArray.count + self.hasUploadedPhotos.count)"
		print("\(offsetX)")
		if offsetX > 64 {
			if !self.navigationBarHide {
				self.navigationController?.setNavigationBarHidden(true, animated: true)
				self.navigationBarHide = true
				print("滑动隐藏")
			}
		}
	}
}

