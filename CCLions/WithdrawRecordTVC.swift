//
//  WithdrawRecordTVC.swift
//  CCLions
//
//  Created by 李冬 on 16/6/15.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WithdrawRecordTVC: UITableViewController, IndicatorInfoProvider {
    
    var itemInfo = IndicatorInfo(title: "View")
    var model: WithdrawRecordModel!
    
    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        initView()
        initNotification()
    }
    
    func initView() -> Void {
        model = WithdrawRecordModel.shareInstance()
        self.tableView.registerNib(UINib(nibName: "WithdrawRecordTVCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: CELL_REUSE)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(hex: "ffffff")
        // 加入下拉刷新和上拉加载
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(WithdrawRecordTVC.refreshAction))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(WithdrawRecordTVC.loadMoreAction))
        tableView.separatorStyle = .SingleLine
        
        // 初始在下拉刷新状态
        // tableView.mj_header.state = MJRefreshState.Refreshing
        self.refreshAction()
    }
    
    /**
     初始化model通知
     */
    func initNotification() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WithdrawRecordTVC.refreshLWithdrawRecordSuccessNotiCallBack(_:)), name: WITHDRAW_RECORD_REFRESH_DATA_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WithdrawRecordTVC.refreshLWithdrawRecordFinishNotiCallBack(_:)), name: WITHDRAW_RECORD_REFRESH_DATA_FINISH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WithdrawRecordTVC.loadMoreLWithdrawRecordSuccessNotiCallBack(_:)), name: WITHDRAW_RECORD_LOAD_MORE_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WithdrawRecordTVC.loadMoreLWithdrawRecordFinishNotiCallBack(_:)), name: WITHDRAW_RECORD_LOAD_MORE_FINISH, object: nil)
    }
    
    func refreshAction() -> Void {
        model.refresh()
    }
    
    func loadMoreAction() -> Void {
        model.loadMore()
    }
    
    func refreshLWithdrawRecordSuccessNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_header.state = MJRefreshState.Idle
        tableView.reloadData()
    }
    
    func refreshLWithdrawRecordFinishNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_header.state = MJRefreshState.Idle
    }
    
    func loadMoreLWithdrawRecordSuccessNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_footer.state = MJRefreshState.Idle
        tableView.reloadData()
    }
    
    func loadMoreLWithdrawRecordFinishNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_footer.state = MJRefreshState.Idle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model.dataArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE, forIndexPath: indexPath) as! WithdrawRecordTVCell
        
        // Configure the cell...
        cell.setParas(model.dataArray[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return HEIGHT_FOR_WITHDRAW_RECORD_CELL
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

