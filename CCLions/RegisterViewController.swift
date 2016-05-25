//
//  RegisterViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/9.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop
import SwiftyJSON
import Alamofire

class RegisterViewController: UIViewController {
// 用户名输入框
	@IBOutlet weak var usernameTextField: UITextField!
	// 密码输入框
	@IBOutlet weak var passwordTextField: UITextField!
	// 确认密码输入框
	@IBOutlet weak var passwordAgainTextField: UITextField!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func close(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	/**
	 点击注册按钮事件

	 - parameter sender: 消息传递者
	 */
	@IBAction func registerAction(sender: AnyObject) {
		// 首先判断资料是否填写完整
		if !infoCompleted() {
			Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
			return
		}

		// 判断两次密码输入是否一致
		if self.passwordTextField.text != self.passwordAgainTextField.text {
			Drop.down(Tips.REGISTER_PASSWORD_NOT_CONSISTENT, state: DropState.Warning)
			return
		}

		// 判断输入是否符合要求的格式
		// 1. 用户名必须是手机号码
		// 2. 密码必须是6位以上
		if Util.isTelNumber(self.usernameTextField.text!) {
			Drop.down(Tips.TEL_NUMBER_FORMAT_ERROR, state: DropState.Warning)
			return
		}

		if self.passwordTextField.text?.characters.count < 6 {
			Drop.down(Tips.PASSWORD_COUNT_LESS_THAN_SIX, state: DropState.Warning)
			return
		}

		// 输入正确之后，发起注册请求
		// 显示正在加载的界面
		SVProgressHUD.showWithStatus("正在注册...")
		// 发起请求
		self.sendRegisterRequest()
	}

	func sendRegisterRequest() -> Void {
		let paras = [
			"username": self.usernameTextField.text!,
			"password": self.passwordTextField.text!.md5,
			"create_time": Util.stringFromDate(NSDate())
		]

		Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_REGISTER.rawValue, parameters: paras)
			.responseJSON { (response) in
				// 返回不为空
				if let value = response.result.value {
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue
					if code == 200 { // 注册成功
						Drop.down(Tips.REGISTER_SUCCESS, state: DropState.Success)
						// 统计注册人数
						self.flurryStatisticsWithName(Statistics.REGISTER_NUMBER, paras: ["target": "register_num"])

						// 进入到登录界面
						self.dismissViewControllerAnimated(true, completion: nil)
					} else {
						let type = json["type"].intValue
						if type == 100 || type == 101 {
							Drop.down(Tips.LOGIN_ERROR, state: DropState.Error)
						} else if type == 102 {
							Drop.down(Tips.REGISTER_USER_HAS_REGISTED, state: DropState.Error)
						}
					}
				} else { // 返回为空，网络连接失败
					// 显示错误信息
					Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
				}

				// 去掉加载界面
				SVProgressHUD.dismiss()
		}
	}

	/**
	 判断资料是否填写完整
	 */
	func infoCompleted() -> Bool {
		if self.usernameTextField.hasText() && self.passwordTextField.hasText() && passwordAgainTextField.hasText() {
			return true
		}
		return false
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
