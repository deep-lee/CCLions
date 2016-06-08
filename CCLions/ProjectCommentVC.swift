//
//  ProjectCommentVC.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

class ProjectCommentVC: UIViewController {

    @IBOutlet var labelTips: UILabel!
    @IBOutlet var mTableView: UITableView!
    var model: ProjectCommentRecordModel!
    var project_id: Int!
    
    var commonFlowView: CommonFlowView!
    var flowTextField: FlowTextFiled!
    
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
        self.model = ProjectCommentRecordModel.shareInstance()
        self.model.project_id = project_id
        self.model.dataArray.removeAll()
        // 加入下拉刷新和上拉加载
        mTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ProjectCommentVC.refreshAction))
        mTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(ProjectCommentVC.loadMoreAction))
        
        // 初始在下拉刷新状态
        mTableView.mj_header.state = MJRefreshState.Refreshing
        
        commonFlowView = CommonFlowView(frame: CGRectZero)
        self.view.insertSubview(commonFlowView, aboveSubview: self.mTableView)
        commonFlowView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(200)
        }
        commonFlowView.delegate = self
        
        flowTextField = FlowTextFiled(frame: CGRectZero)
        self.view.addSubview(flowTextField)
        flowTextField.snp_makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(49)
        }
        flowTextField.textFiled.delegate = self
        flowTextField.textFiled.becomeFirstResponder()
    }
    
    func initNoti() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectCommentVC.refreshDataSuccessNoti(_:)), name: PROJECT_COMMENT_REFRESH_DATA_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectCommentVC.refreshDataFinishNoti(_:)), name: PROJECT_COMMENT_REFRESH_DATA_FINISH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectCommentVC.loadMoreDataSuccessNoti(_:)), name: PROJECT_COMMENT_LOAD_MORE_DATA_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectCommentVC.loadMoreDataFinishNoti(_:)), name: PROJECT_COMMENT_LOAD_MORE_DATA_FINISH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectCommentVC.keyBoardWillHideNoti(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectCommentVC.addCommentSuccessNotiCallBack(_:)), name: PROJECT_COMMENT_ADD_COMMENT_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProjectCommentVC.addCommentFailNotiCallBack(_:)), name: PROJECT_COMMENT_ADD_COMMENT_FAIL, object: nil)
        
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
    
    /**
     添加评论成功回调
     
     - parameter noti: 回调通知
     */
    func addCommentSuccessNotiCallBack(noti: NSNotification) -> Void {
        self.refreshAction()
        self.flowTextField.textFiled.resignFirstResponder()
        self.flowTextField.clearText()
    }
    
    /**
     添加评论失败回调
     
     - parameter noti: 回调通知
     */
    func addCommentFailNotiCallBack(noti: NSNotification) -> Void {
        self.flowTextField.textFiled.becomeFirstResponder()
    }
    
    /**
     监听键盘消失事件
     
     - parameter noti: 通知
     */
    func keyBoardWillHideNoti(noti: NSNotification) -> Void {
        self.flowTextField.hidden = true
    }
    
    func addComment() -> Void {
        print("回调")
        if !self.flowTextField.hasText() {
            return
        }
        
        let paras = [
            "user_id": Util.getLoginedUser()!.id,
            "project_id": self.project_id,
            "content": self.flowTextField.text()
        ]
        
        model.addComment(paras as! [String : AnyObject])
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

extension ProjectCommentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE) as! ProjectCommentRecordTVCell
        let comment = self.model.dataArray[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.setParas(comment)
        return cell
    }
}

extension ProjectCommentVC: CommonFlowViewDelegate {
    func buttonBackClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func buttonCommentClicked() {
        self.flowTextField.hidden = false
        self.flowTextField.textFiled.becomeFirstResponder()
    }
    
    func buttonSupportClicked() {
        
    }
}

extension ProjectCommentVC: UITextFieldDelegate {
    func textFieldDidEndEditing(textField: UITextField) {
        self.addComment()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}
