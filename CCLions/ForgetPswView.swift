//
//  ForgetPswView.swift
//  CCLions
//
//  Created by 李冬 on 16/6/17.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SnapKit
import pop

class ForgetPswView: UIView {

    // 忘记密码控件
    var textFieldUsername: UITextField?
    var textFieldNewPsw: UITextField?
    var textFieldVerCode: UITextField?
    var buttonGetVerCode: UIButton?
    var buttonSure: UIButton?
    var buttonBack: UIButton?
    
    var dismiss: dismissAction?
    var sureAction: RegisterActionCallBack?
    var getVerCodeAction: GetVerCodeCallBack?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() -> Void {
        self.backgroundColor = UIColor.clearColor()
        self.buttonBack = UIButton()
        self.addSubview(buttonBack!)
        buttonBack?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(20)
            make.top.equalTo(40)
            make.size.width.height.equalTo(20)
        })
        buttonBack?.setImage(UIImage(named: "icon-search-back"), forState: UIControlState.Normal)
        buttonBack?.addTarget(self, action: #selector(ForgetPswView.backBtnAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 输入框
        self.textFieldUsername = UITextField()
        self.addSubview(self.textFieldUsername!)
        self.textFieldUsername?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo((buttonBack?.snp_bottom)!).offset(30)
            make.left.equalTo(20)
            make.right.equalTo(20)
            make.height.equalTo(36)
        })
        
        self.textFieldUsername?.placeholder = "手机号码"
        
        self.textFieldNewPsw = UITextField()
        self.addSubview(self.textFieldNewPsw!)
        textFieldNewPsw?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo((textFieldUsername?.snp_bottom)!).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(20)
            make.height.equalTo(36)
        })
        textFieldNewPsw?.placeholder = "密码"
        textFieldNewPsw?.secureTextEntry = true
        
        self.buttonGetVerCode = UIButton()
        self.addSubview(self.buttonGetVerCode!)
        self.buttonGetVerCode?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo((textFieldNewPsw?.snp_bottom)!).offset(20)
            make.right.equalTo(-20)
            make.height.equalTo(36)
            make.width.equalTo(90)
        })
        buttonGetVerCode?.setTitle("获取验证码", forState: UIControlState.Normal)
        buttonGetVerCode?.titleLabel?.font = UIFont.systemFontOfSize(15)
        buttonGetVerCode?.backgroundColor = UIColor(hex: "3C3E53")
        self.buttonGetVerCode?.layer.cornerRadius = 5
        self.buttonGetVerCode?.layer.masksToBounds = true
        buttonGetVerCode?.addTarget(self, action: #selector(ForgetPswView.getVerCodeBtnAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.textFieldVerCode = UITextField()
        self.addSubview(self.textFieldVerCode!)
        self.textFieldVerCode?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(20)
            make.top.equalTo((textFieldNewPsw?.snp_bottom)!).offset(20)
            make.right.equalTo((buttonGetVerCode?.snp_left)!).offset(-20)
            make.height.equalTo(36)
        })
        textFieldVerCode?.placeholder = "验证码"
        
        self.buttonSure = UIButton()
        self.addSubview(buttonSure!)
        buttonSure?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo((textFieldVerCode?.snp_bottom)!).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(40)
        })
        buttonSure?.backgroundColor = UIColor(hex: "3C3E53")
        buttonSure?.setTitle("确认", forState: UIControlState.Normal)
        buttonSure?.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.buttonSure?.layer.cornerRadius = 5
        self.buttonSure?.layer.masksToBounds = true
        buttonSure?.addTarget(self, action: #selector(ForgetPswView.buttonSureAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func backBtnAction(sender: AnyObject) -> Void {
        if self.dismiss != nil {
            self.dismiss!()
        }
    }
    
    func buttonSureAction(sender: AnyObject) -> Void {
        if self.sureAction != nil {
            self.sureAction!(username: (textFieldUsername?.text)!, psw: (textFieldNewPsw?.text)!, verCode: (textFieldVerCode?.text)!)
        }
    }
    
    func getVerCodeBtnAction(sender: AnyObject) -> Void {
        if self.getVerCodeAction != nil {
            self.getVerCodeAction!(username: (textFieldUsername?.text)!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
