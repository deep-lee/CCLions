//
//  LoginView.swift
//  CCLions
//
//  Created by 李冬 on 5/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import SnapKit
import pop

typealias LoginActionCallBack = (username: String, psw: String) -> Void
typealias RegisterActionCallBack = (username: String, psw: String, verCode: String) -> Void
typealias GetVerCodeCallBack = (username: String) -> Void
class LoginView: UIView {

	// 登录控件
	var bgPlayView: LoginBGVideoView? // 背景视频View
	var vipLoginView: VipLoginView?
	var nonVipLoginView: NonVipLoginView?
	var nonVipRegView: NonVipRegisterView?

	var vipLoginBtn: UIButton? // 狮子会会员登录
	var nonVipLoginBtn: UIButton? // 非会员登录
	var nonVipRegisterBtn: UIButton? // 非会员注册
	var forgetPswBtn: UIButton? // 忘记密码

	let BTN_VERTICAL_MARGIN = 20
	let BTN_HEIGHT = 40
	let BTN_MARGIN_SUPERVIEW_BOTTOM = 40
	let BTN_TITLE_FONT_SIZE: CGFloat = 15

	// 登录和注册事件
	var vipLoginCallBack: LoginActionCallBack?
	var nonVipLoginCallBack: LoginActionCallBack?
	var nonVipRegisterCallBAck: RegisterActionCallBack?
	var nonVipRegisterGetVerCodeCallBack: GetVerCodeCallBack?

	/*
	 // Only override drawRect: if you perform custom drawing.
	 // An empty implementation adversely affects performance during animation.
	 override func drawRect(rect: CGRect) {
	 // Drawing code
	 }
	 */
	override init(frame: CGRect) {
		super.init(frame: frame)

		initView()
	}

	/**
	 初始化界面
	 */
	func initView() -> Void {
		// 初始化背景视频界面
		bgPlayView = LoginBGVideoView(frame: self.frame)
		self.addSubview(bgPlayView!)

		self.forgetPswBtn = UIButton()
		self.insertSubview(forgetPswBtn!, aboveSubview: bgPlayView!)
		self.forgetPswBtn?.snp_makeConstraints(closure: { (make) in
			make.left.equalTo(20)
			make.right.equalTo(-20)
			make.bottom.equalTo(-BTN_MARGIN_SUPERVIEW_BOTTOM)
			make.height.equalTo(BTN_HEIGHT)
		})
		self.forgetPswBtn?.setTitle("忘记密码？", forState: UIControlState.Normal)
		self.forgetPswBtn?.backgroundColor = UIColor.clearColor()
		self.forgetPswBtn?.titleLabel?.font = UIFont.systemFontOfSize(12)

		// 初始化登录按钮
		self.nonVipRegisterBtn = UIButton()
		self.insertSubview(nonVipRegisterBtn!, aboveSubview: bgPlayView!)
		self.nonVipRegisterBtn?.snp_makeConstraints(closure: { (make) in
			make.left.equalTo(20)
			make.right.equalTo(-20)
			make.bottom.equalTo((forgetPswBtn?.snp_top)!).offset(-BTN_VERTICAL_MARGIN)
			make.height.equalTo(BTN_HEIGHT)
		})
		self.nonVipRegisterBtn?.setTitle("非狮子会会员注册", forState: UIControlState.Normal)
		self.nonVipRegisterBtn?.backgroundColor = UIColor(hex: "34ADEC")
		self.nonVipRegisterBtn?.titleLabel?.font = UIFont.systemFontOfSize(BTN_TITLE_FONT_SIZE)
		self.nonVipRegisterBtn?.addTarget(self, action: #selector(LoginView.nonVipRegisterAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)

		self.nonVipLoginBtn = UIButton()
		self.insertSubview(nonVipLoginBtn!, aboveSubview: bgPlayView!)
		self.nonVipLoginBtn?.snp_makeConstraints(closure: { (make) in
			make.left.equalTo(20)
			make.right.equalTo(-20)
			make.bottom.equalTo(nonVipRegisterBtn!.snp_top).offset(-BTN_VERTICAL_MARGIN)
			make.height.equalTo(BTN_HEIGHT)
		})
		self.nonVipLoginBtn?.setTitle("非狮子会会员登录", forState: UIControlState.Normal)
		self.nonVipLoginBtn?.backgroundColor = UIColor(hex: "425C9A")
		self.nonVipLoginBtn?.titleLabel?.font = UIFont.systemFontOfSize(BTN_TITLE_FONT_SIZE)
		self.nonVipLoginBtn?.addTarget(self, action: #selector(LoginView.nonVipLoginAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)

		self.vipLoginBtn = UIButton()
		self.insertSubview(vipLoginBtn!, aboveSubview: bgPlayView!)
		self.vipLoginBtn?.snp_makeConstraints(closure: { (make) in
			make.left.equalTo(20)
			make.right.equalTo(-20)
			make.bottom.equalTo(nonVipLoginBtn!.snp_top).offset(-BTN_VERTICAL_MARGIN)
			make.height.equalTo(BTN_HEIGHT)
		})
		self.vipLoginBtn?.setTitle("狮子会会员登录", forState: UIControlState.Normal)
		self.vipLoginBtn?.backgroundColor = UIColor(hex: "425C9A")
		self.vipLoginBtn?.titleLabel?.font = UIFont.systemFontOfSize(BTN_TITLE_FONT_SIZE)
		self.vipLoginBtn?.addTarget(self, action: #selector(LoginView.vipLoinAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)

		// 初始化VIP登录界面
		vipLoginView = VipLoginView(frame: self.frame)
		self.insertSubview(vipLoginView!, aboveSubview: vipLoginBtn!)
		vipLoginView?.hidden = true
		vipLoginView?.dismiss = vipLoginBackBtnAction
		vipLoginView?.loginAction = vipLoginAction

		self.nonVipLoginView = NonVipLoginView(frame: self.frame)
		self.insertSubview(nonVipLoginView!, aboveSubview: vipLoginBtn!)
		nonVipLoginView?.alpha = 0.0
		nonVipLoginView?.dismiss = nonVipLoginBackBtnAction
		nonVipLoginView?.loginAction = nonVipLoginAction

		self.nonVipRegView = NonVipRegisterView(frame: self.frame)
		self.insertSubview(nonVipRegView!, aboveSubview: vipLoginBtn!)
		nonVipRegView?.alpha = 0.0
		nonVipRegView?.dismiss = nonVipRegBackBtnAction
		self.nonVipRegView?.regAction = nonVipRegAction
		self.nonVipRegView?.getVerCodeAction = nonVipRegGetVerCodeAction

	}

// MARK: 狮子会会员登录

	/**
	 会员登录事件

	 - parameter sender:
	 */
	func vipLoinAction(sender: AnyObject) -> Void {
		showVipLoginView()
	}

	/**
	 VIP登录界面返回按钮点击
	 */
	func vipLoginBackBtnAction() -> Void {
		dismissVipLoginView()
	}

	/**
	 消失VIP登录界面
	 */
	func dismissVipLoginView() -> Void {
		let alphaAnimationInc = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		alphaAnimationInc.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		alphaAnimationInc.fromValue = 0.5
		alphaAnimationInc.toValue = 1.0
		alphaAnimationInc.duration = 0.5
		self.bgPlayView!.pop_addAnimation(alphaAnimationInc, forKey: "fade")

		let btnShowAniamtion = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		btnShowAniamtion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		btnShowAniamtion.fromValue = 0.0
		btnShowAniamtion.toValue = 1.0
		btnShowAniamtion.duration = 0.5
		self.vipLoginBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")
		self.nonVipLoginBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")
		self.nonVipRegisterBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")
		self.forgetPswBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")

		let dismissVipLoginAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		dismissVipLoginAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
		dismissVipLoginAnimation.fromValue = 1.0
		dismissVipLoginAnimation.toValue = 0.0
		dismissVipLoginAnimation.duration = 0.5
		self.vipLoginView?.pop_addAnimation(dismissVipLoginAnimation, forKey: "show")
	}

	/**
	 显示VIPLoginView
	 */
	func showVipLoginView() -> Void {
		// 动画显示
		// 显示VIPLoginView
		let alphaAnimationDes = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		alphaAnimationDes.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		alphaAnimationDes.fromValue = 1.0
		alphaAnimationDes.toValue = 0.5
		alphaAnimationDes.duration = 0.5
		self.bgPlayView!.pop_addAnimation(alphaAnimationDes, forKey: "fade")

		let btnDismssAniamtion = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		btnDismssAniamtion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		btnDismssAniamtion.fromValue = 1.0
		btnDismssAniamtion.toValue = 0.0
		btnDismssAniamtion.duration = 0.5
		self.vipLoginBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")
		self.nonVipLoginBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")
		self.nonVipRegisterBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")
		self.forgetPswBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")

		vipLoginView?.hidden = false
		let showVipLoginAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		showVipLoginAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
		showVipLoginAnimation.fromValue = 0.0
		showVipLoginAnimation.toValue = 1.0
		showVipLoginAnimation.duration = 0.5
		self.vipLoginView?.pop_addAnimation(showVipLoginAnimation, forKey: "show")
	}

	func vipLoginAction(username: String, psw: String) -> Void {
		if self.vipLoginCallBack != nil {
			self.vipLoginCallBack!(username: username, psw: psw)
		}
	}

// MARK: 非狮子会会员登录

	/**
	 非会员登录事件

	 - parameter sender:
	 */
	func nonVipLoginAction(sender: AnyObject) -> Void {
		showNonVipLoginView()
	}

	func showNonVipLoginView() -> Void {
		let alphaAnimationDes = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		alphaAnimationDes.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		alphaAnimationDes.fromValue = 1.0
		alphaAnimationDes.toValue = 0.5
		alphaAnimationDes.duration = 0.5
		self.bgPlayView!.pop_addAnimation(alphaAnimationDes, forKey: "fade")

		let btnDismssAniamtion = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		btnDismssAniamtion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		btnDismssAniamtion.fromValue = 1.0
		btnDismssAniamtion.toValue = 0.0
		btnDismssAniamtion.duration = 0.5
		self.vipLoginBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")
		self.nonVipLoginBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")
		self.nonVipRegisterBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")
		self.forgetPswBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")

		let showNonVipLoginAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		showNonVipLoginAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
		showNonVipLoginAnimation.fromValue = 0.0
		showNonVipLoginAnimation.toValue = 1.0
		showNonVipLoginAnimation.duration = 0.5
		self.nonVipLoginView?.pop_addAnimation(showNonVipLoginAnimation, forKey: "show")
	}

	/**
	 VIP登录界面返回按钮点击
	 */
	func nonVipLoginBackBtnAction() -> Void {
		dismissNonVipLoginView()
	}

	/**
	 消失VIP登录界面
	 */
	func dismissNonVipLoginView() -> Void {
		let alphaAnimationInc = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		alphaAnimationInc.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		alphaAnimationInc.fromValue = 0.5
		alphaAnimationInc.toValue = 1.0
		alphaAnimationInc.duration = 0.5
		self.bgPlayView!.pop_addAnimation(alphaAnimationInc, forKey: "fade")

		let btnShowAniamtion = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		btnShowAniamtion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		btnShowAniamtion.fromValue = 0.0
		btnShowAniamtion.toValue = 1.0
		btnShowAniamtion.duration = 0.5
		self.vipLoginBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")
		self.nonVipLoginBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")
		self.nonVipRegisterBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")
		self.forgetPswBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")

		let dismissNonVipLoginAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		dismissNonVipLoginAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
		dismissNonVipLoginAnimation.fromValue = 1.0
		dismissNonVipLoginAnimation.toValue = 0.0
		dismissNonVipLoginAnimation.duration = 0.5
		self.nonVipLoginView?.pop_addAnimation(dismissNonVipLoginAnimation, forKey: "show")
	}

	func nonVipLoginAction(username: String, psw: String) -> Void {
		if self.nonVipLoginCallBack != nil {
			self.nonVipLoginCallBack!(username: username, psw: psw)
		}
	}

// MARK: 非狮子会会员注册
	func nonVipRegisterAction(sender: AnyObject) -> Void {
		showNonVipRegView()
	}

	func showNonVipRegView() -> Void {
		let alphaAnimationDes = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		alphaAnimationDes.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		alphaAnimationDes.fromValue = 1.0
		alphaAnimationDes.toValue = 0.5
		alphaAnimationDes.duration = 0.5
		self.bgPlayView!.pop_addAnimation(alphaAnimationDes, forKey: "fade")

		let btnDismssAniamtion = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		btnDismssAniamtion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		btnDismssAniamtion.fromValue = 1.0
		btnDismssAniamtion.toValue = 0.0
		btnDismssAniamtion.duration = 0.5
		self.vipLoginBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")
		self.nonVipLoginBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")
		self.nonVipRegisterBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")
		self.forgetPswBtn?.pop_addAnimation(btnDismssAniamtion, forKey: "dismiss")

		let showNonVipRegAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		showNonVipRegAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
		showNonVipRegAnimation.fromValue = 0.0
		showNonVipRegAnimation.toValue = 1.0
		showNonVipRegAnimation.duration = 0.5
		self.nonVipRegView?.pop_addAnimation(showNonVipRegAnimation, forKey: "show")
	}

	/**
	 VIP登录界面返回按钮点击
	 */
	func nonVipRegBackBtnAction() -> Void {
		dismissNonVipRegView()
	}

	/**
	 消失VIP登录界面
	 */
	func dismissNonVipRegView() -> Void {
		let alphaAnimationInc = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		alphaAnimationInc.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		alphaAnimationInc.fromValue = 0.5
		alphaAnimationInc.toValue = 1.0
		alphaAnimationInc.duration = 0.5
		self.bgPlayView!.pop_addAnimation(alphaAnimationInc, forKey: "fade")

		let btnShowAniamtion = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		btnShowAniamtion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		btnShowAniamtion.fromValue = 0.0
		btnShowAniamtion.toValue = 1.0
		btnShowAniamtion.duration = 0.5
		self.vipLoginBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")
		self.nonVipLoginBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")
		self.nonVipRegisterBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")
		self.forgetPswBtn?.pop_addAnimation(btnShowAniamtion, forKey: "dismiss")

		let dismissNonVipRegAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
		dismissNonVipRegAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
		dismissNonVipRegAnimation.fromValue = 1.0
		dismissNonVipRegAnimation.toValue = 0.0
		dismissNonVipRegAnimation.duration = 0.5
		self.nonVipRegView?.pop_addAnimation(dismissNonVipRegAnimation, forKey: "show")
	}

	func nonVipRegAction(username: String, psw: String, verCode: String) -> Void {
		if self.nonVipRegisterCallBAck != nil {
			self.nonVipRegisterCallBAck!(username: username, psw: psw, verCode: verCode)
		}
	}

	func nonVipRegGetVerCodeAction(username: String) -> Void {
		if self.nonVipRegisterGetVerCodeCallBack != nil {
			self.nonVipRegisterGetVerCodeCallBack!(username: username)
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
