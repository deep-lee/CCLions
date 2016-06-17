//
//  LoginModel.swift
//  CCLions
//
//  Created by 李冬 on 5/11/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import SwiftyDrop
import Alamofire
import SwiftyJSON

let LOGIN_SUCCESS_NOTIFICATION = "login_success"
let REGISTER_SUCCESS_NOTIFICATION = "register_success"
let FORGET_PSW_SUCCESS_NOTIFICATION = "FORGET_PSW_SUCCESS_NOTIFICATION"

class LoginModel: SuperModel {
	// 单例
	class func shareInstance() -> LoginModel {
		struct Singleton {
			static var onceToken: dispatch_once_t = 0
			static var single: LoginModel?
		}
		dispatch_once(&Singleton.onceToken, {
			Singleton.single = LoginModel()
			}
		)
		return Singleton.single!
	}

	/**
	 获取验证码

	 - parameter username: 手机号
	 */
	func getVerCode(username: String) -> Void {
		SMSSDK.getVerificationCodeByMethod(SMSGetCodeMethodSMS, phoneNumber: username, zone: "86", customIdentifier: nil) { (error) in
			if (error != nil) {
				Drop.down(Tips.GET_VER_CODE_FAIL, state: DropState.Error)
			} else {
				Drop.down(Tips.GET_VER_CODE_SUCCESS, state: DropState.Success)
			}
		}
	}

	/**
	 非会员注册

	 - parameter username: 用户名
	 - parameter psw:      密码
	 - parameter verCode:  验证码
	 */
	func registerNonVip(username: String, psw: String, verCode: String) -> Void {

		SVProgressHUD.showWithStatus(Tips.CONFIRM_VER_CODE)

		// 首先判断验证码是否正确
		SMSSDK.commitVerificationCode(verCode, phoneNumber: username, zone: "86") { (error) in
			if error != nil { // 失败
				Drop.down(Tips.VER_CODE_WRONG, state: DropState.Error)
			} else { // 成功
				SVProgressHUD.showWithStatus(Tips.REGISTING)
				// 发起注册请求
				let paras: [String: AnyObject] = [
					"username": username,
					"password": psw.md5,
					"user_type": UserType.CCLionVip.rawValue,
					"create_time": NSDate()
				]

				// 发起请求
				self.registerRequest(paras)
			}
		}
	}

	/**
	 发起注册请求

	 - parameter paras: 请求参数
	 */
	func registerRequest(paras: [String: AnyObject]) -> Void {
		NetworkUtil.shareInstance().requestWithUrlWithReturnDictionary(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_REGISTER.rawValue, paras: paras) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
			case NetworkResponseState.SUCCESS.rawValue:
				// 发出通知
				self.postNotification(REGISTER_SUCCESS_NOTIFICATION);
			case NetworkResponseState.FAIL.rawValue:
				let type = response.objectForKey(NETWORK_FAIL_TYPE) as! Int
				switch type {
				case 100, 101:
					Drop.down(Tips.REGISTER_FAIL, state: DropState.Error)
				case 102:
					Drop.down(Tips.REGISTER_USER_HAS_REGISTED, state: DropState.Error)
				default:
					break
				}
			default:
				break
			}

			SVProgressHUD.dismiss()
		}
	}

	func login(username: String, psw: String) -> Void {
		SVProgressHUD.showWithStatus(Tips.LOGING)
		let paras = [
			"username": username,
			"password": psw.md5
		]
		loginRequest(paras)
	}

	func loginRequest(paras: [String: AnyObject]) -> Void {
		NetworkUtil.shareInstance().requestWithUrlWithReturnDictionary(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_LOGIN.rawValue, paras: paras) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
			case NetworkResponseState.SUCCESS.rawValue:
				let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [String: AnyObject]
				let data = JSON(dataString)
				let user = Util.getUserFromJson(data)
				// 存储用户信息
				Util.updateUser(user)
				// 记录登录次数数据
				self.flurryStatisticsWithName(Statistics.LOGIN_NUMBER, paras: ["LOGIN_USER_ID": "\(user.id)"])

				// 发出通知
				self.postNotification(LOGIN_SUCCESS_NOTIFICATION);

			case NetworkResponseState.FAIL.rawValue:
				let type = response.objectForKey(NETWORK_FAIL_TYPE) as! Int
				switch type {
				case 100, 101:
					Drop.down(Tips.REGISTER_FAIL, state: DropState.Error)
				case 102:
					Drop.down(Tips.LOGIN_USERNAME_OR_PASSWORD_ERROR, state: DropState.Error)
				default:
					break
				}
			default:
				break
			}

			SVProgressHUD.dismiss()
		}
	}

	/**
	 忘记密码

	 - parameter username: 用户名
	 - parameter psw:      密码
	 - parameter verCode:  验证码
	 */
	func forgetPsw(username: String, psw: String, verCode: String) -> Void {

		SVProgressHUD.showWithStatus(Tips.CONFIRM_VER_CODE)

		// 首先判断验证码是否正确
		SMSSDK.commitVerificationCode(verCode, phoneNumber: username, zone: "86") { (error) in
			if error != nil { // 失败
				Drop.down(Tips.VER_CODE_WRONG, state: DropState.Error)
			} else { // 成功
				SVProgressHUD.showWithStatus(Tips.REGISTING)
				// 发起注册请求
				let paras: [String: AnyObject] = [
					"username": username,
					"password": psw.md5,
				]

				// 发起请求
				self.requestForgetPsw(paras)
			}
		}
	}

	/**
	 发送忘记密码请求

	 - parameter paras: 请求参数
	 */
	func requestForgetPsw(paras: NSDictionary) -> Void {
		NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_FORGET_PSW.rawValue, paras: paras as! [String: AnyObject]) { (response) in
			let state = response.objectForKey(NETWORK_STATE) as! Int
			switch state {
			case NetworkResponseState.CONNECT_FAIL.rawValue:
				Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
			case NetworkResponseState.SUCCESS.rawValue:
				// 发出通知
				self.postNotification(FORGET_PSW_SUCCESS_NOTIFICATION);
			case NetworkResponseState.FAIL.rawValue:
				Drop.down(Tips.FORGET_PSW_FAIL, state: DropState.Error)

			default:
				break
			}

			SVProgressHUD.dismiss()
		}
	}
}