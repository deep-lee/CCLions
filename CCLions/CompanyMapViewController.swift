//
//  CompanyMapViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/9.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop
import SwiftyJSON
import Alamofire

class CompanyMapViewController: UIViewController {
	var mapView: MAMapView!
    var searchBar: UISearchBar!
	var annotations: [MAPointAnnotation]!
	var companyArray: [Company]!
	var flag = true
	var selectedAnnotation: MAPointAnnotation?
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		MAMapServices.sharedServices().apiKey = APIKey
		initMapView()
	}

	/**
	 初始化地图界面
	 */
	func initMapView() -> Void {
		self.annotations = [MAPointAnnotation]()
		self.companyArray = [Company]()
		self.mapView = MAMapView(frame: self.view.bounds)
		self.mapView.delegate = self
		self.view.addSubview(self.mapView)
		// 开启地图定位功能
		self.mapView.showsUserLocation = true
		self.mapView.setUserTrackingMode(MAUserTrackingMode.Follow, animated: true)

		self.mapView.addAnnotations(self.annotations)
		self.mapView.showAnnotations(self.annotations, animated: true)
		// 添加一个搜索框
		self.searchBar = UISearchBar(frame: CGRectMake(0, (self.navigationController?.navigationBar.frame.size.height)!, self.view.frame.size.width, 45))
		self.searchBar.placeholder = "搜索商家"
		// self.searchBar.delegate = self
		self.view.addSubview(self.searchBar)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func leftMenu(sender: AnyObject) {
		slideMenuController()?.toggleLeft()
	}

	/**
	 获取当前地图中心附近20KM范围内的公司

	 - parameter latitude:   纬度
	 - parameter longtitude: 经度
	 */
	func getLocalCompany(latitude: Double, longtitude: Double) -> Void {
		let paras = [
			"local_longitude": "\(longtitude)",
			"local_latitude": "\(latitude)",
			"length": Util.MAP_LIMIT_LENGTH
		]

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_LOCAL_COMPANY.rawValue, parameters: paras as? [String: AnyObject])
			.responseJSON { (response) in
				if let value = response.result.value {
					print(value)
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 {
						self.annotations.removeAll()
						self.companyArray.removeAll()

						let data = json["data"].arrayValue
						for item in data {
							let company = Util.getCompanyFromJson(item)
							company.user_name = item["name"].stringValue
							let coordinate = CLLocationCoordinate2D(latitude: Double(company.address_latitude)!, longitude: Double(company.address_longitude)!)
							let annotation = MAPointAnnotation()
							annotation.coordinate = coordinate
							annotation.title = company.company_name
							annotation.subtitle = company.user_name
							self.annotations.append(annotation)
							self.companyArray.append(company)
						}

						// 显示标注
						dispatch_async(dispatch_get_main_queue(), {
							self.mapView.addAnnotations(self.annotations)
							self.mapView.showAnnotations(self.annotations, animated: true)
						})
					} else {
						Drop.down(Tips.GET_LOCAL_COMPANY_ERROR, state: DropState.Error)
					}
				} else {
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}
		}
	}

	func changeFlag() -> Void {
		self.flag = true
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

extension CompanyMapViewController: MAMapViewDelegate {
	/**
	 接收到定位更新回调

	 - parameter mapView:          地图
	 - parameter userLocation:     位置
	 - parameter updatingLocation: 是否更新
	 */
	func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
		if updatingLocation {
			// print("latitude:\(userLocation.coordinate.latitude), longitude:\(userLocation.coordinate.longitude)")
			if self.flag {
				self.getLocalCompany(userLocation.coordinate.latitude, longtitude: userLocation.coordinate.longitude)
				self.flag = false
			}
		}
	}

	func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
		var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(CELL_REUSE)
		if (annotationView == nil) {
			annotationView = CompanyMapAnnotationView(annotation: annotation, reuseIdentifier: CELL_REUSE)
		}
		annotationView?.canShowCallout = false
		annotationView?.image = UIImage(named: "icon-company")
        annotationView.centerOffset = CGPointMake(0, -16)
		return annotationView
	}

	func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
		print("点击了")
		self.selectedAnnotation = view.annotation as? MAPointAnnotation
	}

	func mapView(mapView: MAMapView!, didSingleTappedAtCoordinate coordinate: CLLocationCoordinate2D) {
		self.selectedAnnotation = nil
	}

	func goToCompanyShowVC(sender: AnyObject) -> Void {
		if (self.selectedAnnotation != nil) {
			let index = self.annotations.indexOf(self.selectedAnnotation!)
			let companyShowViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CompanyShowViewController") as! CompanyShowViewController
			companyShowViewController.company = self.companyArray[index!]
			companyShowViewController.title = "公司详情"
			self.navigationController?.pushViewController(companyShowViewController, animated: true)
		}
	}

	/**
	 地图移动之后调用该函数

	 - parameter mapView:
	 - parameter wasUserAction:
	 */
	func mapView(mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
		print("移动了")
		if wasUserAction {
			self.getLocalCompany(self.mapView.centerCoordinate.latitude, longtitude: self.mapView.centerCoordinate.longitude)
		}
	}
}
