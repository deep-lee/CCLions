//
//  NetworkUtil.swift
//  CCLions
//
//  Created by 李冬 on 5/11/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias NetworkResponse = (response: NSMutableDictionary) -> Void

enum NetworkResponseState: Int {
	case CONNECT_FAIL = 0
	case SUCCESS = 1
	case FAIL = 2
}

let NETWORK_STATE = "network_state"
let NETWORK_FAIL_TYPE = "type"
let NETWORK_SUCCESS_DATA = "data"

class NetworkUtil: NSObject {
	// 单例
	class func shareInstance() -> NetworkUtil {
		struct Singleton {
			static var onceToken: dispatch_once_t = 0
			static var single: NetworkUtil?
		}
		dispatch_once(&Singleton.onceToken, {
			Singleton.single = NetworkUtil()
			}
		)
		return Singleton.single!
	}

	func requestWithUrlWithReturnDictionary(url: String, paras: [String: AnyObject], networkResponse: NetworkResponse) -> Void {
		Alamofire.request(.POST, url, parameters: paras)
			.responseJSON { (response) in
				// 返回不为空
				let dic = NSMutableDictionary()
				if let value = response.result.value {
					print(value)
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 { // 成功
						let data = json["data"].dictionaryObject
						print(data)
						dic.setValue(NetworkResponseState.SUCCESS.rawValue, forKey: NETWORK_STATE)
						dic.setValue(data!, forKey: NETWORK_SUCCESS_DATA)
					} else { // 失败
						let type = json["type"].intValue
						dic.setValue(NetworkResponseState.FAIL.rawValue, forKey: NETWORK_STATE)
						dic.setValue(type, forKey: NETWORK_FAIL_TYPE)
					}
				} else { // 返回为空，网络连接失败
					dic.setValue(NetworkResponseState.CONNECT_FAIL.rawValue, forKey: NETWORK_STATE)
				}

				networkResponse(response: dic)
		}
	}

	func requestWithUrlWithReturnArray(url: String, paras: [String: AnyObject], networkResponse: NetworkResponse) -> Void {
		Alamofire.request(.POST, url, parameters: paras)
			.responseJSON { (response) in
				// 返回不为空
				let dic = NSMutableDictionary()
				if let value = response.result.value {
					print(value)
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 { // 成功
						let data = json["data"].arrayObject
						print(data)
						dic.setValue(NetworkResponseState.SUCCESS.rawValue, forKey: NETWORK_STATE)
						dic.setValue(data, forKey: NETWORK_SUCCESS_DATA)
					} else { // 失败
						let type = json["type"].intValue
						dic.setValue(NetworkResponseState.FAIL.rawValue, forKey: NETWORK_STATE)
						dic.setValue(type, forKey: NETWORK_FAIL_TYPE)
					}
				} else { // 返回为空，网络连接失败
					dic.setValue(NetworkResponseState.CONNECT_FAIL.rawValue, forKey: NETWORK_STATE)
				}

				networkResponse(response: dic)
		}
	}
}