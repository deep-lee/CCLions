//
//  MoreProjectDetailsModel.swift
//  CCLions
//
//  Created by 李冬 on 6/5/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import SwiftyDrop

let GET_MORE_PROJECT_DONATION_RECORD_AMOUNT_SUCCESS = "GET_MORE_PROJECT_DONATION_RECORD_AMOUNT_SUCCESS"
let GET_MORE_PROJECT_WITHDRAW_RECORD_AMOUNT_SUCCESS = "GET_MORE_PROJECT_WITHDRAW_RECORD_AMOUNT_SUCCESS"
let GET_MORE_PROJECT_COMMENT_RECORD_AMOUNT_SUCCESS = "GET_MORE_PROJECT_COMMENT_RECORD_AMOUNT_SUCCESS"

let RECORD_AMOUNT = "record_amount"

class MoreProjectDetailsModel: SuperModel {
	// 单例
	class func shareInstance() -> MoreProjectDetailsModel {
		struct Singleton {
			static var onceToken: dispatch_once_t = 0
			static var single: MoreProjectDetailsModel?
		}
		dispatch_once(&Singleton.onceToken, {
			Singleton.single = MoreProjectDetailsModel()
			}
		)
		return Singleton.single!
	}

	/**
	 获取项目捐款记录数

	 - parameter project_id: 项目id
	 */
	func getProjectDonationRecordAmount(project_id: Int) -> Void {

		SVProgressHUD.show()

		let paras = [
			"project_id": project_id
		]
		NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_PROJECT_DONATION_RECORD_AMOUNT.rawValue, paras: paras) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
			case NetworkResponseState.SUCCESS.rawValue:
				// 获取信息成功
				let object = NSMutableDictionary()

				object.setValue(response.objectForKey(NETWORK_SUCCESS_DATA), forKey: RECORD_AMOUNT)
				self.postNotificationWithName(GET_MORE_PROJECT_DONATION_RECORD_AMOUNT_SUCCESS, object: object)
			case NetworkResponseState.FAIL.rawValue:
				Drop.down(Tips.GET_MORE_PROJECT_DETAILS_ERROR, state: DropState.Error)
			default:
				break
			}

			SVProgressHUD.dismiss()
		}
	}

	/**
	 获取项目提款记录数

	 - parameter project_id: 项目id
	 */
	func getProjectWithdrawRecordAmount(project_id: Int) -> Void {
		SVProgressHUD.show()
		let paras = [
			"project_id": project_id
		]

		NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_PROJECT_WITHDRAW_RECORD_AMOUNT.rawValue, paras: paras) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
			case NetworkResponseState.SUCCESS.rawValue:
				// 获取信息成功
				let object = NSMutableDictionary()

				object.setValue(response.objectForKey(NETWORK_SUCCESS_DATA), forKey: RECORD_AMOUNT)
				self.postNotificationWithName(GET_MORE_PROJECT_WITHDRAW_RECORD_AMOUNT_SUCCESS, object: object)
			case NetworkResponseState.FAIL.rawValue:
				Drop.down(Tips.GET_MORE_PROJECT_DETAILS_ERROR, state: DropState.Error)
			default:
				break
			}

			SVProgressHUD.dismiss()
		}
	}

	func getProjectCommentRcordAmount(project_id: Int) -> Void {
		SVProgressHUD.show()
		let paras = [
			"project_id": project_id
		]

		NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_PROJECT_COMMENT_RECORD_AMOUNT.rawValue, paras: paras) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
			case NetworkResponseState.SUCCESS.rawValue:
				// 获取信息成功
				let object = NSMutableDictionary()

				object.setValue(response.objectForKey(NETWORK_SUCCESS_DATA), forKey: RECORD_AMOUNT)
				self.postNotificationWithName(GET_MORE_PROJECT_COMMENT_RECORD_AMOUNT_SUCCESS, object: object)
			case NetworkResponseState.FAIL.rawValue:
				Drop.down(Tips.GET_MORE_PROJECT_DETAILS_ERROR, state: DropState.Error)
			default:
				break
			}

			SVProgressHUD.dismiss()
		}
	}
}