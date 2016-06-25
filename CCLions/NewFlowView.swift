//
//  NewFlowView.swift
//  CCLions
//
//  Created by 李冬 on 16/6/26.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SnapKit
import pop

protocol NewFlowViewDelegate {
    func buttonBackClicked()
    func buttonLoveClicked()
    func buttonShareClicked()
    func buttonCommentClicked()
}

class NewFlowView: UIView {

    var buttonBack: UIButton!               // 返回按钮
    var buttonLove: UIButton!               // 点赞按钮
    var buttonShare: UIButton!              // 分享按钮
    var buttonComment: UIButton!            // 评论按钮
    
    var delegate: NewFlowViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() {
        // 点赞
        buttonLove = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonLove)
        buttonLove.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.right.equalTo(buttonLove.superview!.snp_centerX).offset(-30)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonLove.backgroundColor = UIColor(hex: "7d7d7d")
        buttonLove.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonLove.layer.masksToBounds = true
        buttonLove.layer.opacity = FLOW_BUTTON_ALPHA
        buttonLove.setImage(UIImage(named: "icon-flow-love"), forState: UIControlState.Normal)
        buttonLove.addTarget(self, action: #selector(NewFlowView.buttonLoveClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 分享
        buttonShare = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonShare)
        buttonShare.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.left.equalTo(buttonShare.superview!.snp_centerX).offset(30)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonShare.backgroundColor = UIColor(hex: "7d7d7d")
        buttonShare.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonShare.layer.masksToBounds = true
        buttonShare.layer.opacity = FLOW_BUTTON_ALPHA
        buttonShare.setImage(UIImage(named: "icon-flow-share"), forState: UIControlState.Normal)
        buttonShare.addTarget(self, action: #selector(NewFlowView.buttonShareClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 返回
        buttonBack = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonBack)
        buttonBack.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.left.equalTo(20)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonBack.backgroundColor = UIColor(hex: "7d7d7d")
        buttonBack.layer.opacity = FLOW_BUTTON_ALPHA
        buttonBack.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonBack.layer.masksToBounds = true
        buttonBack.setImage(UIImage(named: "icon-flow-back"), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: #selector(NewFlowView.buttonBackClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 评论
        buttonComment = UIButton(type: UIButtonType.Custom)
        self.addSubview(buttonComment)
        buttonComment.snp_makeConstraints { (make) in
            make.width.height.equalTo(FLOW_BUTTON_SMALL_WIDTH)
            make.right.equalTo(-20)
            make.bottom.equalTo(FLOW_BOTTOM_OFFSET)
        }
        buttonComment.backgroundColor = UIColor(hex: "7d7d7d")
        buttonComment.layer.cornerRadius = CGFloat(FLOW_BUTTON_SMALL_WIDTH / 2)
        buttonComment.layer.masksToBounds = true
        buttonComment.layer.opacity = FLOW_BUTTON_ALPHA
        buttonComment.setImage(UIImage(named: "icon-flow-comment"), forState: UIControlState.Normal)
        buttonComment.addTarget(self, action: #selector(NewFlowView.buttonCommentClickedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonBackClickedAction(sender: AnyObject) {
        delegate?.buttonBackClicked()
    }
    func buttonLoveClickedAction(sender: AnyObject) {
        delegate?.buttonLoveClicked()
    }
    func buttonShareClickedAction(sender: AnyObject) {
        delegate?.buttonShareClicked()
    }
    func buttonCommentClickedAction(sender: AnyObject) {
        delegate?.buttonCommentClicked()
    }
    
}
