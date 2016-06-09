//
//  FlowView.swift
//  CCLions
//
//  Created by 李冬 on 6/8/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import SnapKit
import pop

protocol FlowViewDelegate {
    func buttonBackClicked()
    func buttonLoveClicked()
    func buttonSupportClicked()
    func buttonShareClicked()
    func buttonCommentClicked()
    func buttonMoreClicked()
    func buttonDonationRecordClicked()
    func buttonWithdrawRecordClicked()
}

/// 底部悬浮界面
class FlowView: UIView {
    
    var buttonBack: UIButton!               // 返回按钮
    var buttonLove: UIButton!               // 点赞按钮
    var buttonSupport: UIButton!            // 支持按钮
    var buttonShare: UIButton!              // 分享按钮
    var buttonMore: UIButton!               // 更多按钮
    
    var buttonComment: UIButton!            // 评论按钮
    var buttonDonationRecord: UIButton!     // 捐款记录按钮
    var buttonWithdrawRecord: UIButton!     // 提款记录按钮
    
    var origiPoint: CGPoint!
    var show = false
    
    var delegate: FlowViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() {
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
        
        buttonMore = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonMore)
        buttonMore.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.right.equalTo(-20)
            // make.centerY.equalTo(buttonMore.superview!)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonMore.backgroundColor = UIColor(hex: "7d7d7d")
        buttonMore.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonMore.layer.masksToBounds = true
        buttonMore.layer.opacity = FLOW_BUTTON_ALPHA
        buttonMore.setImage(UIImage(named: "icon-flow-more-h"), forState: UIControlState.Normal)
        buttonMore.addTarget(self, action: #selector(FlowView.buttonMoreClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 弹出的三个按钮
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
        buttonComment.hidden = true
        buttonComment.addTarget(self, action: #selector(FlowView.buttonCommentClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 捐款记录按钮
        buttonDonationRecord = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonDonationRecord)
        buttonDonationRecord.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.right.equalTo(-20)
            // make.centerY.equalTo(buttonDonationRecord.superview!)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonDonationRecord.backgroundColor = UIColor(hex: "7d7d7d")
        buttonDonationRecord.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonDonationRecord.layer.masksToBounds = true
        buttonDonationRecord.layer.opacity = FLOW_BUTTON_ALPHA
        buttonDonationRecord.setImage(UIImage(named: "icon-donation-record"), forState: UIControlState.Normal)
        buttonDonationRecord.hidden = true
        buttonDonationRecord.addTarget(self, action: #selector(FlowView.buttonDonationRecordClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 提款记录按钮
        buttonWithdrawRecord = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonWithdrawRecord)
        buttonWithdrawRecord.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.right.equalTo(-20)
            // make.centerY.equalTo(buttonWithdrawRecord.superview!)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonWithdrawRecord.backgroundColor = UIColor(hex: "7d7d7d")
        buttonWithdrawRecord.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonWithdrawRecord.layer.masksToBounds = true
        buttonWithdrawRecord.layer.opacity = FLOW_BUTTON_ALPHA
        buttonWithdrawRecord.setImage(UIImage(named: "icon-withdraw-record"), forState: UIControlState.Normal)
        buttonWithdrawRecord.hidden = true
        buttonWithdrawRecord.addTarget(self, action: #selector(FlowView.buttonWithdrawRecordClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonLove = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonLove)
        buttonLove.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.left.equalTo(buttonBack.snp_right).offset(30)
            // make.centerY.equalTo(buttonLove.superview!)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonLove.backgroundColor = UIColor(hex: "7d7d7d")
        buttonLove.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonLove.layer.masksToBounds = true
        buttonLove.layer.opacity = FLOW_BUTTON_ALPHA
        buttonLove.setImage(UIImage(named: "icon-flow-love"), forState: UIControlState.Normal)
        buttonLove.addTarget(self, action: #selector(FlowView.buttonLoveClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonShare = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonShare)
        buttonShare.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.right.equalTo(buttonMore.snp_left).offset(-30)
            // make.centerY.equalTo(buttonShare.superview!)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonShare.backgroundColor = UIColor(hex: "7d7d7d")
        buttonShare.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonShare.layer.masksToBounds = true
        buttonShare.layer.opacity = FLOW_BUTTON_ALPHA
        buttonShare.setImage(UIImage(named: "icon-flow-share"), forState: UIControlState.Normal)
        buttonShare.addTarget(self, action: #selector(FlowView.buttonShareClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showMoreButton() -> Void {
        buttonComment.hidden = false
        buttonWithdrawRecord.hidden = false
        buttonDonationRecord.hidden = false
        
        origiPoint = buttonComment.center
        
        let animation1 = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        animation1.fromValue = origiPoint.y
        animation1.toValue = origiPoint.y - 50
        animation1.duration = 0.5
        buttonComment.layer.pop_addAnimation(animation1, forKey: nil)
        
        let animation2 = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        animation2.fromValue = origiPoint.y
        animation2.toValue = origiPoint.y - 90
        animation2.duration = 0.5
        buttonDonationRecord.layer.pop_addAnimation(animation2, forKey: nil)
        
        let animation3 = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        animation3.fromValue = origiPoint.y
        animation3.toValue = origiPoint.y - 130
        animation3.duration = 0.5
        buttonWithdrawRecord.layer.pop_addAnimation(animation3, forKey: nil)
        
        show = true
    }
    
    func dismissMoreButton() -> Void {
        let animation1 = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        animation1.toValue = origiPoint.y
        animation1.duration = 0.5
        buttonComment.layer.pop_addAnimation(animation1, forKey: nil)
        
        let animation2 = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        animation2.toValue = origiPoint.y
        animation2.duration = 0.5
        buttonDonationRecord.layer.pop_addAnimation(animation2, forKey: nil)
        
        let animation3 = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        animation3.toValue = origiPoint.y
        animation3.duration = 0.5
        buttonWithdrawRecord.layer.pop_addAnimation(animation3, forKey: nil)
        
        self.performSelector(#selector(FlowView.hidden as (FlowView) -> () -> Void), withObject: nil, afterDelay: 0.5)
        
        show = false
    }
    
    func hidden() -> Void {
        buttonComment.hidden = true
        buttonWithdrawRecord.hidden = true
        buttonDonationRecord.hidden = true
    }
    
    
    func buttonBackClickedAction(sender: AnyObject) {
        delegate?.buttonBackClicked()
    }
    func buttonLoveClickedAction(sender: AnyObject) {
        delegate?.buttonLoveClicked()
    }
    func buttonSupportClickedAction(sender: AnyObject) {
        delegate?.buttonSupportClicked()
    }
    func buttonShareClickedAction(sender: AnyObject) {
        delegate?.buttonShareClicked()
    }
    func buttonMoreClickedAction(sender: AnyObject) {
        delegate?.buttonMoreClicked()
        if show {
            self.buttonMore.setImage(UIImage(named: "icon-flow-more-h"), forState: UIControlState.Normal)
            dismissMoreButton()
        } else {
            self.buttonMore.setImage(UIImage(named: "icon-flow-more-v"), forState: UIControlState.Normal)
            showMoreButton()
        }
    }
    func buttonCommentClickedAction(sender: AnyObject) {
        delegate?.buttonCommentClicked()
    }
    func buttonDonationRecordClickedAction(sender: AnyObject) {
        delegate?.buttonDonationRecordClicked()
    }
    func buttonWithdrawRecordClickedAction(sender: AnyObject) {
        delegate?.buttonWithdrawRecordClicked()
    }
}
