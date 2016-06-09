//
//  CommonFlowView.swift
//  CCLions
//
//  Created by 李冬 on 6/8/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import SnapKit

protocol CommonFlowViewDelegate {
    func buttonBackClicked()
    func buttonSupportClicked()
    func buttonCommentClicked()
}

class CommonFlowView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    var buttonBack: UIButton!               // 返回按钮
    var buttonSupport: UIButton!            // 支持按钮
    var buttonComment: UIButton!            // 评论按钮
    
    var delegate: CommonFlowViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() -> Void {
        buttonSupport = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonSupport)
        buttonSupport.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_BIG_WIDTH)
            make.centerX.equalTo(buttonSupport.superview!)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonSupport.backgroundColor = UIColor(hex: "78bc85")
        buttonSupport.layer.cornerRadius = CGFloat(FLOW_BUTTON_BIG_WIDTH / 2)
        buttonSupport.layer.masksToBounds = true
        buttonSupport.layer.opacity = FLOW_BUTTON_ALPHA
        buttonSupport.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        buttonSupport.setTitle("支持", forState: UIControlState.Normal)
        buttonSupport.addTarget(self, action: #selector(FlowView.buttonSupportClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonBack = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonBack)
        buttonBack.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.left.equalTo(20)
            //            make.centerY.equalTo(buttonBack.superview!)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonBack.backgroundColor = UIColor(hex: "7d7d7d")
        buttonBack.layer.opacity = FLOW_BUTTON_ALPHA
        buttonBack.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonBack.layer.masksToBounds = true
        buttonBack.setImage(UIImage(named: "icon-flow-back"), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: #selector(FlowView.buttonBackClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonComment = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonComment)
        buttonComment.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.right.equalTo(-20)
            // make.centerY.equalTo(buttonComment.superview!)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonComment.backgroundColor = UIColor(hex: "7d7d7d")
        buttonComment.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonComment.layer.masksToBounds = true
        buttonComment.layer.opacity = FLOW_BUTTON_ALPHA
        buttonComment.setImage(UIImage(named: "icon-flow-comment"), forState: UIControlState.Normal)
        buttonComment.hidden = false
        buttonComment.addTarget(self, action: #selector(FlowView.buttonCommentClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func buttonBackClickedAction(sender: AnyObject) {
        delegate?.buttonBackClicked()
    }
    
    func buttonSupportClickedAction(sender: AnyObject) {
        delegate?.buttonSupportClicked()
    }
    
    func buttonCommentClickedAction(sender: AnyObject) {
        delegate?.buttonCommentClicked()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideCommentBtn() -> Void {
        self.buttonComment.hidden = true
    }
    
    func hideSupportBtn() -> Void {
        self.buttonSupport.hidden = true
    }
}
