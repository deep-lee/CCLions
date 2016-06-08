//
//  FlowTextFiled.swift
//  CCLions
//
//  Created by 李冬 on 6/9/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import SnapKit

class FlowTextFiled: UIView {

    var textFiled: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() -> Void {
        self.backgroundColor = UIColor(hex: "f2f2f2")
        textFiled = UITextField(frame: CGRectZero)
        self.addSubview(textFiled)
        textFiled.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalTo(textFiled.superview!)
            make.height.equalTo(36)
        }
        textFiled.placeholder = "请输入评论信息"
        textFiled.font = UIFont.systemFontOfSize(15.0)
        textFiled.returnKeyType = UIReturnKeyType.Send
        
        print(textFiled.frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hasText() -> Bool {
        return textFiled.hasText()
    }
    
    func text() -> String {
        return textFiled.text!
    }
    
    func clearText() -> Void {
        textFiled.text = ""
    }
}
