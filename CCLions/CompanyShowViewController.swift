//
//  CompanyShowViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/26.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class CompanyShowViewController: UIViewController {
	
    @IBOutlet weak var topView: UIView!
	@IBOutlet var bottomScrollView: UIScrollView!
    
    var cycleScrollView: SDCycleScrollView!
    
	var companyNameLabel: UILabel?
	var companyIntroTextView: UITextView?
	var company: Company?
    var showImageUrlArray: [String]?
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
        initData()
        initTopScrollView()
        initBottomScrollView()
	}
    
    /**
     初始化公司数据以及展示照片数据
     */
    func initData() -> Void {
        if (self.company != nil) {
            self.showImageUrlArray = self.company?.show_photo.componentsSeparatedByString(";")
            self.showImageUrlArray?.removeLast()
        }
    }

    /**
      初始化顶部的照片展示
     */
	func initTopScrollView() -> Void {
        self.cycleScrollView = SDCycleScrollView(frame: CGRectMake(0, 0, self.topView.frame.size.width, self.topView.frame.size.height), delegate: self, placeholderImage: UIImage(named: "placeholder"))
        cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter
        cycleScrollView.currentPageDotColor = UIColor.whiteColor()
        self.topView.addSubview(self.cycleScrollView)
        if (self.showImageUrlArray != nil) {
            self.cycleScrollView.imageURLStringsGroup = self.showImageUrlArray
        }
	}
    
    /**
     初始化底部的公司介绍界面
     */
    func initBottomScrollView() -> Void {
        self.companyNameLabel = UILabel(frame: CGRectMake(5, 5, self.bottomScrollView.frame.size.width - 10, 20))
        self.companyNameLabel?.font = UIFont.boldSystemFontOfSize(15)
        if (self.company != nil) {
            self.companyNameLabel?.text = self.company?.company_name
        }
        self.bottomScrollView.addSubview(self.companyNameLabel!)
        
        self.companyIntroTextView = UITextView(frame: CGRectMake(5, 5 + self.companyNameLabel!.frame.size.height + 10, self.bottomScrollView.frame.size.width - 10, self.bottomScrollView.frame.size.height))
        if (self.company != nil) {
            self.companyIntroTextView?.text = self.company?.introduction
        }
        self.companyIntroTextView?.editable = false
        self.bottomScrollView.addSubview(self.companyIntroTextView!)
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func contact(sender: AnyObject) {
        
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

extension CompanyShowViewController: SDCycleScrollViewDelegate {
    
}
