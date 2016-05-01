//
//  SearchCompanyViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/9.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyDrop
import SwiftyJSON

class SearchCompanyViewController: UIViewController {
	@IBOutlet var collectionView: UICollectionView!
	var dataArray1: [HotIndustry]!
	var dataArray2: [Company]!
	var cellItemSize: CGSize!
	let kHeaderIdentifier = "kHeaderIdentifier"
	let reuseIdentifier = "SearchCollectionViewCell"

	var searchResult: [Company]!
	var searchTextField: UITextField!

	var hotIndustryCompany: [Company]!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		// initWeight()
		initCollectionView()
		initData()
	}

	func initWeight() -> Void {
		let searchBar = UISearchBar()
		self.navigationItem.titleView = searchBar
	}

	func initCollectionView() -> Void {
		self.dataArray1 = [HotIndustry]()
		self.dataArray2 = [Company]()
		self.searchResult = [Company]()
		self.hotIndustryCompany = [Company]()
		let screenWidth = UIScreen.mainScreen().bounds.size.width
		self.cellItemSize = CGSizeMake(CGFloat((screenWidth - 50) / 4), CGFloat((screenWidth - 50) / 4))
		// self.collectionView.registerClass(HeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderIdentifier)

		self.collectionView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(SearchCompanyViewController.refreshAction))

		// self.collectionView.mj_header.state = MJRefreshState.Refreshing
	}

	func initData() -> Void {
		// 请求获取热门行业信息
		self.dataArray1.removeAll()
		self.dataArray2.removeAll()
		self.queryHotIndustry()
		// self.requestHotCompany()
	}

	func refreshAction() -> Void {
		self.initData()
	}

	/**
	 请求热门行业
	 */
	func queryHotIndustry() -> Void {
		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_HOT_INDUSTRY.rawValue)
			.responseJSON { (response) in
				if let value = response.result.value {
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 {
						let data = json["data"].arrayValue
						for item in data {
							let hot = HotIndustry(id: item["id"].intValue, industry: item["industry"].intValue, show_photo: item["show_photo"].stringValue)
							self.dataArray1.append(hot)
						}

						self.requestHotCompany()
					} else {
						Drop.down(Tips.REQUEST_HOT_INDUSTRY_FAIL, state: DropState.Error)
					}
				} else {
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}
		}
	}

	/**
	 请求热门企业
	 */
	func requestHotCompany() -> Void {
		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_HOT_COMPANY.rawValue)
			.responseJSON { (response) in
				if let value = response.result.value {
					print(value)
					let json = JSON(value)
					let code = json["code"].intValue
					print("code为：\(code)")
					if code == 200 {
						let data = json["data"].arrayValue
						for item in data {
							let company = Company(id: item["id"].intValue, user_id: item["user_id"].intValue, company_name: item["company_name"].stringValue, address_longitude: item["address_longitude"].stringValue, address_latitude: item["address_latitude"].stringValue, business_scope: item["business_scope"].stringValue, industry: item["industry"].intValue, show_photo: item["show_photo"].stringValue, introduction: item["introduction"].stringValue, contact: item["contact"].stringValue, create_time: item["create_time"].stringValue, update_time: item["update_time"].stringValue, company_logo: item["company_logo"].stringValue, hits: item["hits"].intValue)
							company.user_name = item["name"].stringValue
							self.dataArray2.append(company)
						}
						self.collectionView.reloadData()
						self.collectionView.mj_header.state = MJRefreshState.Idle
					} else {
						Drop.down(Tips.REQUEST_HOT_INDUSTRY_FAIL, state: DropState.Error)
					}
				} else {
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}
		}
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

	/**
	 搜索企业

	 - parameter sender: 消息传递者
	 */
	@IBAction func searchCompanyAction(sender: UIButton) -> Void {
		if !self.searchTextField.hasText() {
			Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
			return
		}

		// 发起搜索请求
		self.requestSearch(self.searchTextField.text!)
	}

	func requestSearch(searchText: String) -> Void {
		SVProgressHUD.showWithStatus(Tips.SEARCHING)
		let paras = [
			"search": searchText
		]

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_SEARCH_COMPANY_WITH_TEXT.rawValue, parameters: paras)
			.responseJSON { (response) in
				if let value = response.result.value {
					print(value)
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 {
						self.searchResult.removeAll()
						let data = json["data"].arrayValue
						for item in data {
							let company = Company(id: item["id"].intValue, user_id: item["user_id"].intValue, company_name: item["company_name"].stringValue, address_longitude: item["address_longitude"].stringValue, address_latitude: item["address_latitude"].stringValue, business_scope: item["business_scope"].stringValue, industry: item["industry"].intValue, show_photo: item["show_photo"].stringValue, introduction: item["introduction"].stringValue, contact: item["contact"].stringValue, create_time: item["create_time"].stringValue, update_time: item["update_time"].stringValue, company_logo: item["company_logo"].stringValue, hits: item["hits"].intValue)
							company.user_name = item["name"].stringValue
							self.searchResult.append(company)
						}

						if self.searchResult.count != 0 {
							self.goToSearchResultVC()
						} else {
							Drop.down(Tips.SEARCH_NO_RESULT, state: DropState.Warning)
						}
					} else {
						Drop.down(Tips.SEARCH_COMPANY_FAIL, state: DropState.Error)
					}
				} else {
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}

				SVProgressHUD.dismiss()
		}
	}

	func goToSearchResultVC() -> Void {
		let searchResultViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchResultViewController") as! SearchResultViewController
		searchResultViewController.dataArray = self.searchResult
		self.navigationController?.pushViewController(searchResultViewController, animated: true)
	}

	func goToCompanyShowVC(row: Int) -> Void {
		let companyShowViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CompanyShowViewController") as! CompanyShowViewController
		companyShowViewController.company = self.dataArray2[row]
		companyShowViewController.title = "公司详情"
		self.navigationController?.pushViewController(companyShowViewController, animated: true)
	}

	func goToHotIndustryCompanyVC() -> Void {
		let searchResultViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchResultViewController") as! SearchResultViewController
		searchResultViewController.dataArray = self.hotIndustryCompany
		self.navigationController?.pushViewController(searchResultViewController, animated: true)
	}

	func getHotIndustryCompany(row: Int) -> Void {
		SVProgressHUD.show()
		let paras = [
			"industry": self.dataArray1[row].industry
		]

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_HOT_INDUSTRY_COMPANY.rawValue, parameters: paras)
			.responseJSON { (response) in
				if let value = response.result.value {
					print(value)
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 {
						self.hotIndustryCompany.removeAll()
						let data = json["data"].arrayValue
						for item in data {
							let company = Company(id: item["id"].intValue, user_id: item["user_id"].intValue, company_name: item["company_name"].stringValue, address_longitude: item["address_longitude"].stringValue, address_latitude: item["address_latitude"].stringValue, business_scope: item["business_scope"].stringValue, industry: item["industry"].intValue, show_photo: item["show_photo"].stringValue, introduction: item["introduction"].stringValue, contact: item["contact"].stringValue, create_time: item["create_time"].stringValue, update_time: item["update_time"].stringValue, company_logo: item["company_logo"].stringValue, hits: item["hits"].intValue)
							company.user_name = item["name"].stringValue
							self.hotIndustryCompany.append(company)
						}

						if self.hotIndustryCompany.count != 0 {
							// self.goToSearchResultVC()
							self.goToHotIndustryCompanyVC()
						} else {
							Drop.down(Tips.HOT_INDUSTRY_FAIL, state: DropState.Warning)
						}
					} else {
						Drop.down(Tips.SEARCH_COMPANY_FAIL, state: DropState.Error)
					}
				} else {
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}

				SVProgressHUD.dismiss()
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
		let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderIdentifier, forIndexPath: indexPath)

		let label = headerView.viewWithTag(1) as! UILabel
		let searchTextField = headerView.viewWithTag(2) as! UITextField
		let searchButton = headerView.viewWithTag(3) as! UIButton
		if indexPath.section == 0 {
			label.text = "热门行业"
			searchButton.addTarget(self, action: #selector(SearchCompanyViewController.searchCompanyAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
			searchTextField.hidden = false
			searchButton.hidden = false
			searchTextField.addTarget(self, action: #selector(SearchCompanyViewController.searchCompanyAction(_:)), forControlEvents: UIControlEvents.EditingDidEndOnExit)
			self.searchTextField = searchTextField
		} else if indexPath.section == 1 {
			label.text = "热门企业"
			searchButton.hidden = true
			searchTextField.hidden = true
		}
		return headerView
	}

	func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
		return self.cellItemSize
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! SearchCollectionViewCell
		if indexPath.section == 0 {
			let item = self.dataArray1[indexPath.row]
			cell.showImageView.sd_setImageWithURL(NSURL(string: item.show_photo))
			cell.showLabel.text = Util.INDUSTRY[item.industry]
		} else if indexPath.section == 1 {
			cell.showImageView.sd_setImageWithURL(NSURL(string: self.dataArray2[indexPath.row].company_logo))
			cell.showLabel.hidden = true
		}

		return cell
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
		if indexPath.section == 1 { // 热门企业
			self.goToCompanyShowVC(indexPath.row)
		} else if indexPath.section == 0 {
			self.getHotIndustryCompany(indexPath.row)
		}
	}
}
