//
//  NonVipRegister.swift
//  CCLions
//
//  Created by 李冬 on 5/11/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

class NonVipRegisterView: UIView {

	var usernameTextField: UITextField?
	var pswTextField: UITextField?
	var verCodeTextField: UITextField?
	var regBtn: UIButton?
	var backBtn: UIButton?
	var verCodeBtn: UIButton?

	var dismiss: dismissAction?
	var regAction: RegisterActionCallBack?
	var getVerCodeAction: GetVerCodeCallBack?

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

	func initView() -> Void {
		self.backgroundColor = UIColor.clearColor()
		self.backBtn = UIButton()
		self.addSubview(backBtn!)
		backBtn?.snp_makeConstraints(closure: { (make) in
			make.left.equalTo(20)
			make.top.equalTo(40)
			make.size.width.height.equalTo(20)
		})
		backBtn?.setImage(UIImage(named: "icon-search-back"), forState: UIControlState.Normal)
		backBtn?.addTarget(self, action: #selector(NonVipRegisterView.backBtnAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)

		// 输入框
		self.usernameTextField = UITextField()
		self.addSubview(self.usernameTextField!)
		self.usernameTextField?.snp_makeConstraints(closure: { (make) in
			make.top.equalTo((backBtn?.snp_bottom)!).offset(30)
			make.left.equalTo(20)
			make.right.equalTo(20)
			make.height.equalTo(36)
		})

		self.usernameTextField?.placeholder = "手机号码"

		self.pswTextField = UITextField()
		self.addSubview(self.pswTextField!)
		pswTextField?.snp_makeConstraints(closure: { (make) in
			make.top.equalTo((usernameTextField?.snp_bottom)!).offset(20)
			make.left.equalTo(20)
			make.right.equalTo(20)
			make.height.equalTo(36)
		})
		pswTextField?.placeholder = "密码"
		pswTextField?.secureTextEntry = true

		self.verCodeBtn = UIButton()
		self.addSubview(self.verCodeBtn!)
		self.verCodeBtn?.snp_makeConstraints(closure: { (make) in
			make.top.equalTo((pswTextField?.snp_bottom)!).offset(20)
			make.right.equalTo(-20)
			make.height.equalTo(36)
			make.width.equalTo(90)
		})
		verCodeBtn?.setTitle("获取验证码", forState: UIControlState.Normal)
		verCodeBtn?.titleLabel?.font = UIFont.systemFontOfSize(15)
		verCodeBtn?.backgroundColor = UIColor(hex: "3C3E53")
        self.verCodeBtn?.layer.cornerRadius = 5
        self.verCodeBtn?.layer.masksToBounds = true
		verCodeBtn?.addTarget(self, action: #selector(NonVipRegisterView.getVerCodeBtnAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)

		self.verCodeTextField = UITextField()
		self.addSubview(self.verCodeTextField!)
		self.verCodeTextField?.snp_makeConstraints(closure: { (make) in
			make.left.equalTo(20)
			make.top.equalTo((pswTextField?.snp_bottom)!).offset(20)
			make.right.equalTo((verCodeBtn?.snp_left)!).offset(-20)
			make.height.equalTo(36)
		})
		verCodeTextField?.placeholder = "验证码"

		self.regBtn = UIButton()
		self.addSubview(regBtn!)
		regBtn?.snp_makeConstraints(closure: { (make) in
			make.top.equalTo((verCodeTextField?.snp_bottom)!).offset(20)
			make.left.equalTo(20)
			make.right.equalTo(-20)
			make.height.equalTo(40)
		})
		regBtn?.backgroundColor = UIColor(hex: "3C3E53")
		regBtn?.setTitle("注册", forState: UIControlState.Normal)
		regBtn?.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.regBtn?.layer.cornerRadius = 5
        self.regBtn?.layer.masksToBounds = true
		regBtn?.addTarget(self, action: #selector(NonVipRegisterView.regBtnAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
	}

	func backBtnAction(sender: AnyObject) -> Void {
		if self.dismiss != nil {
			self.dismiss!()
		}
	}

	func regBtnAction(sender: AnyObject) -> Void {
		if self.regAction != nil {
			self.regAction!(username: (usernameTextField?.text)!, psw: (pswTextField?.text)!, verCode: (verCodeTextField?.text)!)
		}
	}

	func getVerCodeBtnAction(sender: AnyObject) -> Void {
		if self.getVerCodeAction != nil {
			self.getVerCodeAction!(username: (usernameTextField?.text)!)
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
