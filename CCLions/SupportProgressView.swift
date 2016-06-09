//
//  SupportProgressView.swift
//  CCLions
//
//  Created by 李冬 on 6/9/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

class SupportProgressView: UIView {

    var labelHasRaisedAmount: UILabel!              // 已经筹得的金额
    var labelTotalAmount: UILabel!                  // 总共需要筹的金额
    var progressView: LDProgressView!               // 进度条
    var labelProgress: UILabel!                     // 进度
    var labelPeopleSupport: UILabel!                // 多少人支持
    var labelLeftTime: UILabel!                     // 剩余时间
    
    var pecent: CGFloat!                            // 进度
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() -> Void {
        labelHasRaisedAmount = UILabel(frame: CGRectZero)
        self.addSubview(labelHasRaisedAmount)
        labelHasRaisedAmount.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(20)
            make.right.equalTo(-20)
            //make.height.equalTo(40)
        }
        labelHasRaisedAmount.textAlignment = NSTextAlignment.Left
        labelHasRaisedAmount.textColor = UIColor(hex: "555555")
        labelHasRaisedAmount.font = UIFont.systemFontOfSize(15.0)
        
        labelTotalAmount = UILabel(frame: CGRectZero)
        self.addSubview(labelTotalAmount)
        labelTotalAmount.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalTo(labelHasRaisedAmount)
           // make.height.equalTo(40)
        }
        labelTotalAmount.textAlignment = NSTextAlignment.Right
        labelTotalAmount.textColor = UIColor(hex: "555555")
        labelTotalAmount.font = UIFont.systemFontOfSize(12.0)
        
        progressView = LDProgressView(frame: CGRectZero)
        self.addSubview(progressView)
        progressView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(labelHasRaisedAmount.snp_bottom).offset(15)
            make.height.equalTo(10)
        }
        progressView.delegate = self
        
        labelProgress = UILabel(frame: CGRectZero)
        self.addSubview(labelProgress)
        labelProgress.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(progressView.snp_bottom).offset(15)
            // make.height.equalTo(36)
        }
        labelProgress.textAlignment = NSTextAlignment.Left
        labelProgress.textColor = UIColor(hex: "aaaaaa")
        labelProgress.font = UIFont.systemFontOfSize(12.0)
        
        labelPeopleSupport = UILabel(frame: CGRectZero)
        self.addSubview(labelPeopleSupport)
        labelPeopleSupport.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalTo(labelProgress)
            // make.height.equalTo(36)
        }
        labelPeopleSupport.textAlignment = NSTextAlignment.Center
        labelPeopleSupport.textColor = UIColor(hex: "aaaaaa")
        labelPeopleSupport.font = UIFont.systemFontOfSize(12.0)
        
        labelLeftTime = UILabel(frame: CGRectZero)
        self.addSubview(labelLeftTime)
        labelLeftTime.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalTo(labelProgress)
            // make.height.equalTo(36)
        }
        labelLeftTime.textAlignment = NSTextAlignment.Right
        labelLeftTime.textColor = UIColor(hex: "aaaaaa")
        labelLeftTime.font = UIFont.systemFontOfSize(12.0)
    }
    
    /**
     设置已经筹得的金额
     
     - parameter amount: 金额
     */
    func setHasRaisedAmount(amount: Int) -> Void {
        self.labelHasRaisedAmount.text = "已筹总额：￥\(amount)"
        progressView.setCurrentProgress(CGFloat(amount))
    }
    
    /**
     设置总得筹款金额
     
     - parameter amount: 金额
     */
    func setTotalAmount(amount: Int) -> Void {
        self.labelTotalAmount.text = "目标金额：￥\(amount)"
        progressView.setTotalProgress(CGFloat(amount))
    }
    
    func setSupportPeople(amount: String) -> Void {
        self.labelPeopleSupport.text = amount + "人支持"
    }
    
    func setLeftTime(time: Int) -> Void {
        self.labelLeftTime.text = "剩余\(time)天"
    }
    
    func setPercent(percent: CGFloat) -> Void {
        self.labelProgress.text = String(format: "%.1f", percent * 100) + "%"
    }
    
    func setParas(project: Project) -> Void {
        setTotalAmount(project.fundraising_amount)
        setHasRaisedAmount(project.has_raised_amount)
        setLeftTime(project.left_time)
    }
}

extension SupportProgressView: LDProgressViewDelegate {
    func percentChanged(percent: CGFloat) {
        self.pecent = percent
        setPercent(percent)
    }
}