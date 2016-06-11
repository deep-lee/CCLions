//
//  PickPositionOnMapViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/24.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop

let APIKey = "c8ae2ff34b5f1a87bd61304e1f75dba9"
typealias pickPositionSendValue = (row: Int, annotation: MAAnnotation) -> Void
class PickPositionOnMapViewController: UIViewController {
	var mapView: MAMapView!
	var searchBar: UISearchBar!
	var search: AMapSearchAPI!
	var annotations: [MAPointAnnotation]!
	var selectedAnnotation: MAPointAnnotation?
	var myClosure: pickPositionSendValue?
	var row: Int?
    var userLocation: MAUserLocation!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		MAMapServices.sharedServices().apiKey = APIKey
		self.annotations = [MAPointAnnotation]()
		self.initMapView()
		self.initSearch()
		self.initWeight()
        self.initNoti()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func initWeight() -> Void {
		let btn = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PickPositionOnMapViewController.save(_:)))
		self.navigationItem.rightBarButtonItem = btn
	}
    
    func initNoti() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PickPositionOnMapViewController.selectButtonClickedNotiCallBack(_:)), name: SELECT_COMPANY_POSITION_BUTTON_CLICKED, object: nil)
    }

	func save(sender: AnyObject) -> Void {
		if self.selectedAnnotation == nil {
			Drop.down(Tips.PICK_ANNOTATION_ERROR, state: DropState.Warning)
			return
		}

		if self.myClosure != nil {
			myClosure!(row: self.row!, annotation: self.selectedAnnotation!)
			self.navigationController?.popViewControllerAnimated(true)
		}
	}

	func setClosure(closure: pickPositionSendValue) -> Void {
		self.myClosure = closure
	}

	/**
	 初始化地图界面
	 */
	func initMapView() -> Void {
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
		self.searchBar.placeholder = "搜索地图"
		self.searchBar.delegate = self
		self.view.addSubview(self.searchBar)
	}

	/**
	 初始化搜索
	 */
	func initSearch() -> Void {
		AMapSearchServices.sharedServices().apiKey = APIKey
		self.search = AMapSearchAPI()
		self.search.delegate = self
	}

	func searchText(text: String) -> Void {
		print("正在搜索")
		self.selectedAnnotation = nil
		self.searchBar.resignFirstResponder()
		let searchRequest = AMapPOIKeywordsSearchRequest()
		searchRequest.keywords = text
		searchRequest.requireExtension = true
		searchRequest.types = "公司企业"
		self.search.AMapPOIKeywordsSearch(searchRequest)
	}

    
    func selectButtonClickedNotiCallBack(noti: NSNotification) -> Void {
        let dic = noti.object as! NSDictionary
        let title = dic.objectForKey(POSITION_TITLE) as! String
        
        var annotation = getAnnotationFromPositionTitle(title)
        
        if title == userLocation.title {
            annotation = userLocation
        }

        if annotation == nil {
            Drop.down(Tips.PICK_ANNOTATION_ERROR, state: DropState.Warning)
            return
        }
        
        if self.myClosure != nil {
            myClosure!(row: self.row!, annotation: annotation!)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func getAnnotationFromPositionTitle(title: String) -> MAAnnotation? {
        for item in self.annotations {
            if item.title == title {
                return item
            }
        }
        
        return nil
    }
    
    func getLocationName() -> Void {
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.locationWithLatitude(CGFloat(userLocation.coordinate.latitude), longitude: CGFloat(userLocation.coordinate.longitude))
        regeo.requireExtension = true
        self.search.AMapReGoecodeSearch(regeo)
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

extension PickPositionOnMapViewController: MAMapViewDelegate {
	/**
	 接收到定位更新回调

	 - parameter mapView:          地图
	 - parameter userLocation:     位置
	 - parameter updatingLocation: 是否更新
	 */
	func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        self.userLocation = userLocation
        if updatingLocation {
            // 发起逆地理编码
            getLocationName()
        }
	}

	func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
		var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(CELL_REUSE)
		if (annotationView == nil) {
			annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: CELL_REUSE)
		}
        if (annotation.title == CURRENT_POSITION) || (annotation.title == userLocation.title) {
            annotationView?.image = UIImage(named: "icon-my-location")
        } else {
            annotationView?.image = UIImage(named: "icon-company")
        }
        
        annotationView.canShowCallout = false
        annotationView.centerOffset = CGPointMake(0, -16)
		return annotationView
	}

    func mapView(mapView: MAMapView!, didAddAnnotationViews views: [AnyObject]!) {
        let view = views.first as! MAAnnotationView
        if view.annotation.isKindOfClass(MAUserLocation.self) {
            let pre = MAUserLocationRepresentation()
            pre.fillColor = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 0.3)
            pre.strokeColor = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 1.0)
            pre.image = UIImage(named: "icon-my-location")
            pre.lineWidth = 3
            pre.lineDashPattern = [6, 3]
            self.mapView.updateUserLocationRepresentation(pre)
            view.calloutOffset = CGPointMake(0, 0)
        }
        
    }
    
	func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
		self.selectedAnnotation = view.annotation as? MAPointAnnotation
	}

	func mapView(mapView: MAMapView!, didSingleTappedAtCoordinate coordinate: CLLocationCoordinate2D) {
		self.selectedAnnotation = nil
	}
    
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode != nil {
            let regeocode = response.regeocode
            self.userLocation.title = regeocode.formattedAddress
        }
    }
}

extension PickPositionOnMapViewController: AMapSearchDelegate {
	func onPOISearchDone(request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
		print(response.pois.count)
		print(response.pois)
		self.mapView.removeAnnotations(self.annotations)
		self.annotations.removeAll()
		for item in response.pois as! [AMapPOI] {
			let coordinate = CLLocationCoordinate2D(latitude: Double(item.location.latitude), longitude: Double(item.location.longitude))
			let anotation = MAPointAnnotation()
			anotation.coordinate = coordinate
			anotation.title = item.name
			anotation.subtitle = item.address
			print(item.name)
			self.annotations.append(anotation)
		}

		self.mapView.addAnnotations(self.annotations)
		self.mapView.showAnnotations(self.annotations, animated: true)
	}
}

extension PickPositionOnMapViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		// 开始搜索
		self.searchText(self.searchBar.text!)
	}
}
