//
//  SuperModel.swift
//  CCLions
//
//  Created by Joseph on 16/5/20.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import SwiftyJSON

class SuperModel: NSObject {
	func postNotification(name: String) -> Void {
		NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil);
	}

	func postNotificationWithName(name: String, object: AnyObject?) -> Void {
		NSNotificationCenter.defaultCenter().postNotificationName(name, object: object)
	}

	/**
	 更新登录的用户信息
	 */
	func updateLoginedUserInfo() -> Void {
		if Util.hasUserLogined() {
			let paras = [
				"userId": "\(Util.getLoginedUser()?.id)"
			]

			NetworkUtil.shareInstance().requestWithUrlWithReturnDictionary(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_USER_INFO_WITH_ID.rawValue, paras: paras, networkResponse: { (response) in
				let state = response.objectForKey(NETWORK_STATE) as! Int
				if state == NetworkResponseState.SUCCESS.rawValue {
					let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [String: AnyObject]
					let data = JSON(dataString)
					let user = Util.getUserFromJson(data)
					// 存储登录用户的信息
					Util.updateUser(user)
				}
			})
		}
	}
}
