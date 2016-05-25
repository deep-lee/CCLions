//
//  VipLoginView.swift
//  CCLions
//
//  Created by 李冬 on 5/11/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

typealias dismissAction = (Void) -> Void!
class VipLoginView: UIView {
    
    // 狮子会会员登录输入框
    var usernameTextField: UITextField?
    var pswTextField: UITextField?
    var loginBtn: UIButton?
    var backBtn: UIButton?
    
    var dismiss: dismissAction?
    var loginAction: LoginActionCallBack?
    
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
        backBtn?.addTarget(self, action: #selector(VipLoginView.backBtnAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 输入框
        self.usernameTextField = UITextField()
        self.addSubview(self.usernameTextField!)
        self.usernameTextField?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo((backBtn?.snp_bottom)!).offset(30)
            make.left.equalTo(20)
            make.right.equalTo(20)
            make.height.equalTo(36)
        })
        
        self.usernameTextField?.placeholder = "狮子会会员编号"
        
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
        
        self.loginBtn = UIButton()
        self.addSubview(loginBtn!)
        loginBtn?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo((pswTextField?.snp_bottom)!).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(40)
        })
        loginBtn?.backgroundColor = UIColor(hex: "3C3E53")
        loginBtn?.setTitle("登录", forState: UIControlState.Normal)
        loginBtn?.titleLabel?.font = UIFont.systemFontOfSize(15)
        loginBtn?.addTarget(self, action: #selector(VipLoginView.loginBtnAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func backBtnAction(sender: AnyObject) -> Void {
        if self.dismiss != nil {
            self.dismiss!()
        }
    }
    
    func loginBtnAction(sender: AnyObject) -> Void {
        if self.loginAction != nil {
            self.loginAction!(username: (usernameTextField?.text)!, psw: (pswTextField?.text)!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
