//
//  MyProjectVC.swift
//  CCLions
//
//  Created by 李冬 on 6/13/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

class MyProjectVC: ButtonBarPagerTabStripViewController {
    
    var isReload = false

    var commonFlowView: CommonFlowView!
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clearColor()
        settings.style.selectedBarBackgroundColor = .orangeColor()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.hidesBackButton = true
        
        buttonBarView.removeFromSuperview()
        navigationController?.navigationBar.addSubview(buttonBarView)
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = .whiteColor()
            
            if animated {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
                })
            }
            else {
                newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }
        }
        
        initView()
    }
    
    func initView() -> Void {
        commonFlowView = CommonFlowView(frame: CGRectZero)
        self.view.insertSubview(commonFlowView, atIndex: 10)
        commonFlowView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(64)
        }
        commonFlowView.delegate = self
        commonFlowView.hideCommentBtn()
        commonFlowView.hideSupportBtn()
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = SupportedProjectTVC(style: .Plain, itemInfo: "支持的项目")
        let child_2 = LaunchedProjectTVC(style: .Plain, itemInfo: "发起的项目")
        
        guard isReload else {
            return [child_1, child_2]
        }
        
        var childViewControllers = [child_1, child_2]
        
        for (index, _) in childViewControllers.enumerate(){
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        let nItems = 1 + (rand() % 2)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if rand() % 2 == 0 {
            pagerBehaviour = .Progressive(skipIntermediateViewControllers: rand() % 2 == 0 , elasticIndicatorLimit: rand() % 2 == 0 )
        }
        else {
            pagerBehaviour = .Common(skipIntermediateViewControllers: rand() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
    
    override func configureCell(cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo) {
        super.configureCell(cell, indicatorInfo: indicatorInfo)
        cell.backgroundColor = .clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.－＊／
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        buttonBarView.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.addSubview(buttonBarView)
    }
}

extension MyProjectVC: CommonFlowViewDelegate {
    func buttonBackClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func buttonCommentClicked() {
        
    }
    
    func buttonSupportClicked() {
        
    }
}
