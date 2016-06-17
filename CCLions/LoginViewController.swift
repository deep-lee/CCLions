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

	var loginView: LoginView?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		initView()
		initNoti()
	}

	/**
	 初始化界面
	 */
	func initView() -> Void {
		self.loginView = LoginView(frame: self.view.frame)
		self.view.addSubview(self.loginView!)
		self.loginView?.vipLoginCallBack = vipLoginAction
		self.loginView?.nonVipLoginCallBack = nonVipLoginAction
		self.loginView?.nonVipRegisterCallBAck = nonVipRegAction
		self.loginView?.nonVipRegisterGetVerCodeCallBack = getVerCodeAction
        self.loginView?.forgetPswGetVerCodeCallBack = getVerCodeAction
        self.loginView?.foregtPswSureCallBack = forgetPswSureAction
	}

	/**
	 初始化通知
	 */
	func initNoti() -> Void {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.loginSuccessNoti(_:)), name: LOGIN_SUCCESS_NOTIFICATION, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.regSuccessNoti(_:)), name: REGISTER_SUCCESS_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.forgetPswSuccessNotiCallBack(_:)), name: FORGET_PSW_SUCCESS_NOTIFICATION, object: nil)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/**
	 会员登录

	 - parameter username: 用户名
	 - parameter psw:      密码
	 */
	func vipLoginAction(username: String, psw: String) -> Void {
		print("登录")
		if username.isEmpty || psw.isEmpty {
			Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
			return
		}
		LoginModel.shareInstance().login(username, psw: psw)
	}

	/**
	 非会员登录

	 - parameter username: 用户名
	 - parameter psw:      密码
	 */
	func nonVipLoginAction(username: String, psw: String) -> Void {
		if username.isEmpty || psw.isEmpty {
			Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
			return
		}

		LoginModel.shareInstance().login(username, psw: psw)
	}

	/**
	 非会员注册

	 - parameter username: 用户名
	 - parameter psw:      密码
	 - parameter verCode:  验证码
	 */
	func nonVipRegAction(username: String, psw: String, verCode: String) -> Void {
		print(" 正在注册")
		if username.isEmpty || psw.isEmpty || verCode.isEmpty {
			Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
			return
		}
		LoginModel.shareInstance().registerNonVip(username, psw: psw, verCode: verCode)
	}

	/**
	 获取验证码

	 - parameter username: 手机号
	 - parameter verCode:  验证码
	 */
	func getVerCodeAction(username: String) -> Void {
		print("正在获取验证码")
		if username.isEmpty {
			Drop.down(Tips.USERNAME_CAN_NOT_EMPTY, state: DropState.Warning)
			return
		}

		// 获取验证码
		LoginModel.shareInstance().getVerCode(username)
	}
    
    func forgetPswSureAction(username: String, psw: String, verCode: String) -> Void {
        if username.isEmpty || psw.isEmpty || verCode.isEmpty {
            Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
            return
        }
        LoginModel.shareInstance().forgetPsw(username, psw: psw, verCode: verCode)
    }

	/**
	 登陆成功通知

	 - parameter noti: 通知
	 */
	func loginSuccessNoti(noti: NSNotification) -> Void {
		// 判断当前用户资料是否填写完整
		if Util.hasUserCompletedInfo() {
			// 进入到主界面
			self.goToMainActivity()
		} else {
			// 进入到资料填写界面
			self.goToCompleteInfoVC()
		}
	}

	/**
	 注册成功通知

	 - parameter noti: 通知
	 */
	func regSuccessNoti(noti: NSNotification) -> Void {
		self.loginView?.dismissNonVipRegView()
	}

    func forgetPswSuccessNotiCallBack(noti: NSNotification) -> Void {
        self.loginView?.dismissForgetPswView()
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
}
