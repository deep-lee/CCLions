//
//  LDProgressView.swift
//  CCLions
//
//  Created by 李冬 on 6/9/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import SnapKit
import pop

protocol LDProgressViewDelegate {
    func percentChanged(percent: CGFloat)
}

/// 自定义ProgressView
class LDProgressView: UIView {

    var viewBase: UIView!               // 底层的View
    var viewProgress: UIView!           // 进度View
    var progress: CGFloat!              // 当前进度
    var total: CGFloat!                 // 总得进度
    var percent: CGFloat!               // 比例
    
    var delegate: LDProgressViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() -> Void {
        viewBase = UIView(frame: CGRectMake(20, 0, SCREEN_WIDH - 40, PROGRESS_VIEW_HEIGHT))
        self.addSubview(viewBase)
        viewBase.backgroundColor = UIColor(hex: "b0cfb0")
        viewBase.layer.cornerRadius = 2.5
        viewBase.layer.masksToBounds = true
        
        viewProgress = UIView(frame: CGRectMake(20, 0, SCREEN_WIDH - 40, PROGRESS_VIEW_HEIGHT))
        self.addSubview(viewProgress)
        viewProgress.backgroundColor = UIColor(hex: "38a453")
        viewProgress.layer.cornerRadius = 2.5
        viewProgress.layer.masksToBounds = true
        
        progress = 0
        total = 0
        percent = 0
    }
    
    func setBaseViewBackgroundColor(color: UIColor) -> Void {
        self.viewBase.backgroundColor = color
    }
    
    func setProgressViewBackgroundColor(color: UIColor) -> Void {
        self.viewProgress.backgroundColor = color
    }
    
    func setCurrentProgress(progress: CGFloat) -> Void {
        self.progress = progress
        updateProgressViewFrame()
    }
    
    func setTotalProgress(total: CGFloat) -> Void {
        self.total = total
        updateProgressViewFrame()
    }
    
    func updateProgressViewFrame() -> Void {
        percent = self.progress / self.total
        
        if percent > 1 {
            return
        }
        
        let width = (SCREEN_WIDH - 40) * percent
        self.viewProgress.width = width
        
        delegate?.percentChanged(self.percent)
    }

}
