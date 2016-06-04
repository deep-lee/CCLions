//
//  MainVCModel.swift
//  CCLions
//
//  Created by Joseph on 16/5/12.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyDrop
import SwiftyJSON

let REFRESH_DATA_SUCCESS = "REFRESH_DATA_SUCCESS"
let REFRESH_DATA_FINISH = "REFRESH_DATA_FINISH"
let LOAD_MORE_DATA_SUCCESS = "LOAD_MORE_DATA_SUCCESS"
let LOAD_MORE_DATA_FINISH = "LOAD_MORE_DATA_FINISH"
let GO_TO_SEARCH_PROJECT = "GO_TO_SEARCH_PROJECT"
let ADD_FAV_SUCCESS = "ADD_FAV_SUCCESS"

class MainVCModel: SuperModel {
	var dataArray: [Project]!
	var searchResult: [Project]!
	// 已展示的最后一条数据的id
	var lastId = Int.max
	// 单例
	class func shareInstance() -> MainVCModel {
		struct Singleton {
			static var onceToken: dispatch_once_t = 0
			static var single: MainVCModel?
		}
		dispatch_once(&Singleton.onceToken, {
			Singleton.single = MainVCModel()
			Singleton.single?.dataArray = [Project]()
			Singleton.single?.searchResult = [Project]()
			}
		)
		return Singleton.single!
	}

	// refresh
	// 下拉刷新
	// */
	func headerRefresh() -> Void {
		self.lastId = Int.max
		print("正在下拉刷新")
		let paras = [
			"lastId": self.lastId
		]
		NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_PROJECT_PAGE.rawValue, paras: paras) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				self.postNotification(REFRESH_DATA_FINISH)
			case NetworkResponseState.SUCCESS.rawValue:
				let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
				let data = JSON(dataString).arrayValue
				if data.count != 0 {
					self.dataArray.removeAll()
					for item in data {
						let project = Project(id: item["id"].intValue,
							title: item["title"].stringValue,
							time: item["time"].stringValue,
							launcher_id: item["launcher_id"].intValue,
							favorite: item["favorite"].intValue,
							cover_image: item["cover_image"].stringValue,
							details_page: item["details_page"].stringValue,
							project_type: item["project_type"].intValue,
							fundraising_amount: item["fundraising_amount"].intValue,
							has_raised_amount: item["has_raised_amount"].intValue,
							withdraw_amount: item["withdraw_amount"].intValue,
							apply_for_other: item["apply_for_other"].intValue,
							aided_person_id_num: item["aided_person_id_num"].stringValue,
							aided_person_id_card_photo: item["aided_person_id_card_photo"].stringValue,
							left_time: item["left_time"].intValue,
							sponsorship_company_id: item["sponsorship_company_id"].intValue,
							create_time: item["create_time"].stringValue,
							name: item["name"].stringValue)

						self.dataArray.append(project)
					}
					// 重新加载TableView数据
					self.postNotification(REFRESH_DATA_SUCCESS)
					self.lastId = (self.dataArray.last?.id)!
				}
			case NetworkResponseState.FAIL.rawValue:
				Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
				self.postNotification(REFRESH_DATA_FINISH)
			default:
				break
			}
		}
	}

	/**
	 上拉加载更多
	 */
	func footerLoadMore() -> Void {
		print("正在加载更多")
		let paras = [
			"lastId": self.lastId
		]

		NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_PROJECT_PAGE.rawValue, paras: paras) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				self.postNotification(LOAD_MORE_DATA_FINISH)
			case NetworkResponseState.SUCCESS.rawValue:
				let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
				let data = JSON(dataString).arrayValue
				if data.count != 0 {
					for item in data {
						let project = Project(id: item["id"].intValue,
							title: item["title"].stringValue,
							time: item["time"].stringValue,
							launcher_id: item["launcher_id"].intValue,
							favorite: item["favorite"].intValue,
							cover_image: item["cover_image"].stringValue,
							details_page: item["details_page"].stringValue,
							project_type: item["project_type"].intValue,
							fundraising_amount: item["fundraising_amount"].intValue,
							has_raised_amount: item["has_raised_amount"].intValue,
							withdraw_amount: item["withdraw_amount"].intValue,
							apply_for_other: item["apply_for_other"].intValue,
							aided_person_id_num: item["aided_person_id_num"].stringValue,
							aided_person_id_card_photo: item["aided_person_id_card_photo"].stringValue,
							left_time: item["left_time"].intValue,
							sponsorship_company_id: item["sponsorship_company_id"].intValue,
							create_time: item["create_time"].stringValue,
							name: item["name"].stringValue)

						self.dataArray.append(project)
					}
					// 重新加载TableView数据
					self.postNotification(LOAD_MORE_DATA_SUCCESS)
					self.lastId = (self.dataArray.last?.id)!
				}
			case NetworkResponseState.FAIL.rawValue:
				Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
				self.postNotification(LOAD_MORE_DATA_FINISH)
			default:
				break
			}
		}
	}

	/**
	 搜索

	 - parameter text: 搜索文本
	 */
	func requestSearchWithText(text: String) -> Void {
		// 统计搜索的内容
		self.flurryStatisticsWithName(Statistics.SEARCH_ACTIVITY_CONTENT, paras: ["search_activity": text])

		SVProgressHUD.show()
		let paras = [
			"search_text": text
		]

		NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_SEARCH_PROJECT.rawValue, paras: paras) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
			case NetworkResponseState.SUCCESS.rawValue:
				let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
				let data = JSON(dataString).arrayValue
				if data.count != 0 {
					for item in data {
						let project = Project(id: item["id"].intValue,
							title: item["title"].stringValue,
							time: item["time"].stringValue,
							launcher_id: item["launcher_id"].intValue,
							favorite: item["favorite"].intValue,
							cover_image: item["cover_image"].stringValue,
							details_page: item["details_page"].stringValue,
							project_type: item["project_type"].intValue,
							fundraising_amount: item["fundraising_amount"].intValue,
							has_raised_amount: item["has_raised_amount"].intValue,
							withdraw_amount: item["withdraw_amount"].intValue,
							apply_for_other: item["apply_for_other"].intValue,
							aided_person_id_num: item["aided_person_id_num"].stringValue,
							aided_person_id_card_photo: item["aided_person_id_card_photo"].stringValue,
							left_time: item["left_time"].intValue,
							sponsorship_company_id: item["sponsorship_company_id"].intValue,
							create_time: item["create_time"].stringValue,
							name: item["name"].stringValue)

						self.searchResult.append(project)
					}

					if self.searchResult.count != 0 {
						self.postNotification(GO_TO_SEARCH_PROJECT)
					} else {
						Drop.down(Tips.SEARCH_NO_RESULT, state: DropState.Warning)
					}
				} else {
					Drop.down(Tips.SEARCH_NO_RESULT, state: DropState.Warning)
				}
			case NetworkResponseState.FAIL.rawValue:
				Drop.down(Tips.SEARCH_PROJECT_FAIL, state: DropState.Error)
			default:
				break
			}
		}
	}

	func requestFav(user_id: Int, project_id: Int) -> Void {
		let paras = [
			"user_id": "\(user_id)",
			"project_id": "\(project_id)"
		]

		NetworkUtil.shareInstance().requestWithUrlWithReturnDictionary(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ADD_FAV.rawValue, paras: paras) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
			case NetworkResponseState.SUCCESS.rawValue:
				// 点赞成功
				self.postNotification(ADD_FAV_SUCCESS)
			case NetworkResponseState.FAIL.rawValue:
				let type = response.objectForKey(NETWORK_FAIL_TYPE) as! Int
				switch type {
				case 100, 101:
					Drop.down(Tips.ADD_FAV_FAIL, state: DropState.Error)
				case 102:
					Drop.down(Tips.ADD_FAV_AGAIN, state: DropState.Info)
				default:
					break
				}
			default:
				break
			}
		}
	}
}