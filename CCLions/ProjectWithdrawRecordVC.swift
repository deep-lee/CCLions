//
//  ProjectWithdrawRecordVC.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

class ProjectWithdrawRecordVC: UIViewController {

    @IBOutlet var labelTips: UILabel!
    @IBOutlet var mTableView: UITableView!
    var model: ProjectWithdrawRecordModel!
    var project_id: Int!
    
    var commonFlowView: CommonFlowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() -> Void {
        initNoti()
        self.model = ProjectWithdrawRecordModel.shareInstance()
        self.model.project_id = project_id
        self.model.dataArray.removeAll()
        // 加入下拉刷新和上拉加载
        mTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ProjectWithdrawRecordVC.refreshAction))
        mTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(ProjectWithdrawRecordVC.loadMoreAction))
        
        // 初始在下拉刷新状态
        mTableView.mj_header.state = MJRefreshState.Refreshing
        
        commonFlowView = CommonFlowView(frame: CGRectZero)
        self.view.insertSubview(commonFlowView, aboveSubview: self.mTableView)
        commonFlowView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(200)
        }
        commonFlowView.hideCommentBtn()
        commonFlowView.delegate = self
    }
    
    func initNoti() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectWithdrawRecordVC.refreshDataSuccessNoti(_:)), name: PROJECT_WITHDRAW_REFRESH_DATA_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectWithdrawRecordVC.refreshDataFinishNoti(_:)), name: PROJECT_WITHDRAW_REFRESH_DATA_FINISH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectWithdrawRecordVC.loadMoreDataSuccessNoti(_:)), name: PROJECT_WITHDRAW_LOAD_MORE_DATA_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectWithdrawRecordVC.loadMoreDataFinishNoti(_:)), name: PROJECT_WITHDRAW_LOAD_MORE_DATA_FINISH, object: nil)
    }
    
    func refreshDataSuccessNoti(noti: NSNotification) -> Void {
        mTableView.mj_header.state = MJRefreshState.Idle
        mTableView.reloadData()
        if model.dataArray.count == 0 {
            self.labelTips.hidden = false
            self.mTableView.hidden = true
        } else {
            self.labelTips.hidden = true
            self.mTableView.hidden = false
        }
    }
    
    func refreshDataFinishNoti(noti: NSNotification) -> Void {
        mTableView.mj_header.state = MJRefreshState.Idle
        if model.dataArray.count == 0 {
            self.labelTips.hidden = false
            self.mTableView.hidden = true
        } else {
            self.labelTips.hidden = true
            self.mTableView.hidden = false
        }
    }
    
    func loadMoreDataSuccessNoti(noti: NSNotification) -> Void {
        mTableView.mj_footer.state = MJRefreshState.Idle
        mTableView.reloadData()
    }
    
    func loadMoreDataFinishNoti(noti: NSNotification) -> Void {
        mTableView.mj_footer.state = MJRefreshState.Idle
    }
    
    func refreshAction() -> Void {
        self.model.refresh()
    }
    
    func loadMoreAction() -> Void {
        self.model.loadMore()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProjectWithdrawRecordVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE) as! ProjectWithdrawRecordTVCell
        let withdraw = self.model.dataArray[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.setParas(withdraw)
        return cell
    }
}

extension ProjectWithdrawRecordVC: CommonFlowViewDelegate {
    func buttonBackClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func buttonCommentClicked() {
        
    }
    
    func buttonSupportClicked() {
        
    }
}
