//
//  SearhView.swift
//  CCLions
//
//  Created by 李冬 on 16/5/1.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

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
		backBtn = UIButton(frame: CGRectMake(10, frame.size.height / 2, 20, 20))
		backBtn.setImage(UIImage(named: "icon-search-back"), forState: UIControlState.Normal)
		backBtn.addTarget(self, action: #selector(SearhView.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
		self.addSubview(backBtn)

		searchTextField = UITextField(frame: CGRectMake(40, frame.size.height / 2 - 4, UIScreen.mainScreen().bounds.size.width - 50, 30))
		searchTextField.borderStyle = UITextBorderStyle.None
		searchTextField.placeholder = "搜索项目"
		searchTextField.returnKeyType = UIReturnKeyType.Search
		searchTextField.becomeFirstResponder()
		searchTextField.addTarget(self, action: #selector(SearhView.searchTextFieldDidEndOnExit(_:)), forControlEvents: UIControlEvents.EditingDidEndOnExit)
		self.addSubview(searchTextField)
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
}
