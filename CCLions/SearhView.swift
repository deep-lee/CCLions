//
//  SearhView.swift
//  CCLions
//
//  Created by 李冬 on 16/5/1.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SnapKit

class SearhView: UIView {
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    var backBtn: UIButton!
    var searchTextField: UITextField!
    
    var buttonCallBack: (() -> ())?
    var searchTextFieldEndCallBack: (() -> ())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hex: "f5f5f5")
        
        backBtn = UIButton(frame: CGRectZero)
        self.addSubview(backBtn)
        backBtn.snp_makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalTo(backBtn.superview!)
            make.left.equalTo(10)
        }
        backBtn.setImage(UIImage(named: "icon-search-back"), forState: UIControlState.Normal)
        backBtn.addTarget(self, action: #selector(SearhView.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        CGRectMake(40, frame.size.height / 2 - 4, UIScreen.mainScreen().bounds.size.width - 50, 30)
        searchTextField = UITextField(frame: CGRectZero)
        self.addSubview(searchTextField)
        searchTextField.snp_makeConstraints { (make) in
            make.left.equalTo(backBtn.snp_right).offset(10)
            make.centerY.equalTo(searchTextField.superview!)
            make.right.equalTo(-10)
        }
        searchTextField.borderStyle = UITextBorderStyle.None
        searchTextField.placeholder = "搜索项目"
        searchTextField.returnKeyType = UIReturnKeyType.Search
        searchTextField.addTarget(self, action: #selector(SearhView.searchTextFieldDidEndOnExit(_:)), forControlEvents: UIControlEvents.EditingDidEndOnExit)
        
    }
    
    func searchTextFieldDidEndOnExit(sender: AnyObject) -> Void {
        if searchTextField.hasText() {
            searchTextFieldEndCallBack!()
        }
    }
    
    func buttonClicked(sender: AnyObject) -> Void {
        buttonCallBack!()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getInputText() -> String {
        return self.searchTextField.text!
    }
    
    func clearInput() -> Void {
        self.searchTextField.text = ""
    }
}
