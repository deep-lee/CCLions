//
//  CompanyShowViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/26.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit

let MARGIN_LEFT: CGFloat = 15

class CompanyShowViewController: UIViewController {
    @IBOutlet var mTableView: UITableView!

	var cycleScrollView: SDCycleScrollView!

	var companyNameLabel: UILabel?
	var companyIntroTextView: UITextView?
	var company: Company?
	var showImageUrlArray: [String]?
    var introHeight: CGFloat!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
        initSizeForIntroduction()
		initData()
		initTopScrollView()
		updateCompanyHits()
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
        let headerView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDH, 200))
		self.cycleScrollView = SDCycleScrollView(frame: CGRectMake(0, 0, SCREEN_WIDH, 200), delegate: self, placeholderImage: UIImage(named: "placeholder"))
		cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter
		cycleScrollView.currentPageDotColor = UIColor.whiteColor()
		headerView.addSubview(self.cycleScrollView)
        mTableView.tableHeaderView = headerView
		if (self.showImageUrlArray != nil) {
			self.cycleScrollView.imageURLStringsGroup = self.showImageUrlArray
		}
	}
    
    func initSizeForIntroduction() -> Void {
        // let font = UIFont(name: "HelveticaNeue", size: 15.0)
        let companyIntro = self.company!.introduction as NSString
        let size = companyIntro.boundingRectWithSize(CGSizeMake(SCREEN_WIDH - MARGIN_LEFT * 2, CGFloat(Int.max)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15.0)], context: nil).size
        introHeight = size.height
        print(introHeight)
    }

//	/**
//	 初始化底部的公司介绍界面
//	 */
//	func initBottomScrollView() -> Void {
//		self.companyNameLabel = UILabel(frame: CGRectZero)
//        self.bottomScrollView.addSubview(self.companyNameLabel!)
//        self.companyNameLabel?.snp_makeConstraints(closure: { (make) in
//            make.top.equalTo(5)
//            make.left.equalTo(5)
//            make.right.equalTo(-5)
//        })
//		self.companyNameLabel?.font = UIFont.boldSystemFontOfSize(15)
//		if (self.company != nil) {
//			self.companyNameLabel?.text = self.company?.company_name
//		}
//    
//		self.companyIntroTextView = UITextView(frame: CGRectZero)
//        self.bottomScrollView.addSubview(self.companyIntroTextView!)
//        self.companyIntroTextView?.snp_makeConstraints(closure: { (make) in
//            make.top.equalTo((companyNameLabel?.snp_bottom)!).offset(8)
//            make.left.equalTo(5)
//            make.right.equalTo(-5)
//            make.bottom.equalTo((companyIntroTextView?.superview)!)
//        })
//		if (self.company != nil) {
//			self.companyIntroTextView?.text = self.company?.introduction
//		}
//		self.companyIntroTextView?.editable = false
//		
//	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func contact(sender: AnyObject) {
		let callWebView = UIWebView()
		let telUrl = NSURL(string: "tel:" + (self.company?.contact)!)
		callWebView.loadRequest(NSURLRequest(URL: telUrl!))
		self.view.addSubview(callWebView)
	}

	/**
	 更新公司点击量
	 */
	func updateCompanyHits() -> Void {
		let paras = [
			"id": "\(self.company?.id)"
		]
		print(paras)
		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_UPDATE_COMPANY_HITS.rawValue, parameters: paras)
			.responseJSON { (response) in
				print(response.result.value)
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

extension CompanyShowViewController: SDCycleScrollViewDelegate {
}

extension CompanyShowViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return introHeight
        }
        
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE, forIndexPath: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = self.company?.company_name
        case 1:
            let label = UILabel(frame: CGRectZero)
            cell.addSubview(label)
            label.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(MARGIN_LEFT)
                make.right.equalTo(-MARGIN_LEFT)
                make.height.equalTo(introHeight)
            })
            label.text = self.company?.introduction
            label.font = UIFont.systemFontOfSize(15.0)
            label.numberOfLines = 0
            label.textColor = UIColor(hex: "838283")
            
        case 2:
            cell.textLabel?.textColor = UIColor(hex: "838283")
            cell.textLabel?.text = "公司地址"
            cell.detailTextLabel?.text = self.company?.address_position
            cell.detailTextLabel?.textColor = UIColor(hex: "838283")
        default:
            break
        }
        
        return cell
    }
}
