//
//  BottomItemView.swift
//  CCLions
//
//  Created by Joseph on 16/5/12.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class BottomItemView: UIView {
    
    var _labelText: UILabel!
    var _imageViewIcon: UIImageView!
    var _imageIcon: UIImage!
    var _textShow: String!
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(imageIcon: UIImage, textShow: String) {
        super.init(frame: CGRectZero)
        
        _imageIcon = imageIcon
        _textShow = textShow
        
        initView()
    }
    
    func initView() -> Void {
        
        _imageViewIcon = UIImageView(image: _imageIcon)
        self.addSubview(_imageViewIcon)
        let superView = self
        _imageViewIcon.snp_makeConstraints { (make) in
            make.top.equalTo(14)
            make.centerX.equalTo(superView)
            make.width.height.equalTo(30)
        }
        
        _labelText = UILabel()
        self.addSubview(_labelText)
        _labelText.snp_makeConstraints { (make) in
            make.top.equalTo(_imageViewIcon.snp_bottom).offset(8)
            make.centerX.equalTo(superView)
        }
        _labelText.text = _textShow
        _labelText.font = UIFont.systemFontOfSize(12)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
