//
//  CustomCalloutView.swift
//  CCLions
//
//  Created by 李冬 on 6/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import SnapKit

/// 自定义地图标注点击气泡界面
class CustomCalloutView: UIView {

    var labelPosition: UILabel!
    var buttonSelect: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
    }
 
    func initView() -> Void {
        self.backgroundColor = UIColor.clearColor()
        labelPosition = UILabel(frame: CGRectZero)
        self.addSubview(labelPosition)
        labelPosition.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(10)
        }
        labelPosition.font = UIFont.systemFontOfSize(15.0)
        labelPosition.textColor = UIColor.whiteColor()
        
        buttonSelect = UIButton()
        self.addSubview(buttonSelect)
        buttonSelect.snp_makeConstraints { (make) in
            make.top.equalTo(labelPosition.snp_bottom).offset(10)
            make.centerX.equalTo(buttonSelect.superview!)
        }
        buttonSelect.backgroundColor = UIColor.clearColor()
        buttonSelect.setTitle("选择", forState: UIControlState.Normal)
    }
    
}
