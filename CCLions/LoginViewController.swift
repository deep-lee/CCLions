//
//  LoginViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/9.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop
import Alamofire
import SwiftyJSON
import SlideMenuControllerSwift

class LoginViewController: UIViewController {
/// 用户名输入框
	@IBOutlet weak var usernameTextField: UITextField!
	/// 密码输入框
	@IBOutlet weak var passwordTextField: UITextField!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/**
	 进入到注册界面

	 - parameter sender: 消息传递者
	 */
	@IBAction func goToRegisterViewController(sender: AnyObject) {
		let registerVC = self.storyboard?.instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
		self.presentViewController(registerVC, animated: true, completion: nil)
	}

	/**
	 登录事件

	 - parameter sender: 消息传递者
	 */
	@IBAction func loginAction(sender: AnyObject) {
		// 首先判断资料是否填写完整
		if !infoCompleted() {
			Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
			return
		}

		// 输入正确之后，发起登录请求
		// 显示正在加载的界面
		SVProgressHUD.showWithStatus("正在登录...")
		// 发送请求
        self.sendLoginRequest()
	}

	/**
	 判断信息是否填写完整

	 - returns: 完整->yes
	 */
	func infoCompleted() -> Bool {
		if self.usernameTextField.hasText() && self.passwordTextField.hasText() {
			return true
		}

		return false
	}
    
    func sendLoginRequest() -> Void {
        let paras = [
            "username" : self.usernameTextField.text!,
            "password" : self.passwordTextField.text!.md5
        ]
        
        Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_LOGIN.rawValue, parameters: paras)
        .responseJSON { (response) in
            // 返回不为空
            if let value = response.result.value {
                // 解析json
                let json = JSON(value)
                let code = json["code"].intValue
                if code == 200 { // 登录成功
                    // 获取登录的用户信息
                    let data = json["data"]
                    let user = User(id: data["id"].intValue, username: data["username"].stringValue, password: data["password"].stringValue, header: data["header"].stringValue, name: data["name"].stringValue, sex: data["sex"].intValue, address: data["address"].stringValue, contact: data["contact"].stringValue, service_team: data["service_team"].stringValue, update_time: data["update_time"].stringValue)
                    
                    // 存储登录用户的信息
                    Util.updateUser(user)
                    
                    // 此时需要判断当前登录的用户资料是否已经填写了
                    // 如果没有填写，则进入到资料填写界面
                    if (user.name == nil || user.name == "") {
                        // 进入到资料填写界面
                        self.goToCompleteInfoVC()
                    } else {
                        // 已经完成了资料的填写，进入到主界面
                        self.goToMainActivity()
                    }
                } else {  // 参数缺少或数据库操作失败
                    let type = json["type"].intValue
                    if type == 100 || type == 101 {
                        Drop.down(Tips.LOGIN_ERROR, state: DropState.Error)
                    } else if type == 102 {
                        Drop.down(Tips.LOGIN_USERNAME_OR_PASSWORD_ERROR, state: DropState.Error)
                    }
                }
                
            } else {  // 返回为空，也就是网络连接失败
                // 显示错误信息
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
            }
            
            // 去掉加载界面
            SVProgressHUD.dismiss()
        }
    }
    
    /**
     进入到主界面
     */
    func goToMainActivity() -> Void {
        let leftViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SlideViewController") as! SlideViewController
        
        let nvc: UINavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("MainNavagationController") as! UINavigationController
        nvc.navigationBar.barTintColor = UIColor(hex: "0395d8")
        leftViewController.mainViewController = nvc
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        self.presentViewController(slideMenuController, animated: true, completion: nil)
    }
    
    /**
     进入到完成用户资料界面
     */
    func goToCompleteInfoVC() -> Void {
        // 进入到资料填写界面
        let editSelfProfileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EditSelfProfileViewController") as! EditSelfProfileViewController
        let nvc = UINavigationController(rootViewController: editSelfProfileViewController)
        editSelfProfileViewController.flag = false
        nvc.navigationBar.barTintColor = UIColor(hex: "0395d8")
        let dic = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        nvc.navigationBar.titleTextAttributes = dic
        nvc.navigationBar.tintColor = UIColor.whiteColor()
        self.presentViewController(nvc, animated: true, completion: nil)
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
